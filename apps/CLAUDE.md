# CLAUDE.md

## Handoff note (2026-09-01, machine switch)

Picking this up on a new machine? Start here, in order:
1. **Sign-Out modal touch bug has a fix applied** (§4/§6 item 1): `LogoutCustomBottomSheetWidget` now shows itself via `showGeneralDialog` (with an explicit `Material` ancestor) instead of `showModalBottomSheet` — the `ModalBottomSheetRoute` path in this app was silently swallowing taps on its own buttons for reasons never fully root-caused (network, `TextButton`, drag-recognizer, and root-navigator were all ruled out first; see `xdocs/mobile_customization_log.md`). The fix was observed working live (logout requests firing, session clearing, landing back on the login screen) across repeated test rounds on the emulator, but the tap-by-tap correlation during manual ADB-driven testing got noisy near the end — **treat it as fix-applied-and-probably-working, not yet independently confirmed clean. Verify manually first** before considering this closed.
2. Registration and login are **confirmed working** as of 2026-08-31 — don't re-litigate "auth is broken" from scratch; re-read that investigation first if it resurfaces.
3. `git status` on `Apps/` as of this handoff: clean working tree, everything below is already committed on `feat/firebase`. Verify that's still true before assuming anything.
4. Environment this was tested in: `meatsoko_test` AVD (Android emulator), User app via `flutter run -d emulator-5554`. iOS still doesn't build (§4) — don't lose time on iOS unless that's specifically next.

## 1. Project overview

Two Flutter mobile apps for **MeatSoko**, a Kenyan meat/livestock e-commerce marketplace:

- **`User app/`** — customer-facing shopping app (Dart package `user_app`, Android/iOS id `com.meatsokogroup.user`)
- **`Vendor app/`** — seller-facing app: catalog management, orders, POS, delivery-staff management (Dart package `vendor_app`, id `com.meatsokogroup.vendor`)

Both are built from the licensed **6valley** Flutter e-commerce template (6amTech) — this was not built from scratch, it's a customization of a purchased template. They talk to the same Laravel backend as the MeatSoko web storefront, which lives in a **separate sibling repo** (`../Admin and web new install V16.2.1/`, its own git history) — production API: `https://shop.meatsokogroup.com`.

This repo (`github.com/meatsoko/mobile_app.git`) was split out of the monolithic web/backend repo on 2026-08-30 specifically so mobile and web/backend can be versioned and deployed independently. There is a third companion app referenced in the ecosystem ("Deliveryman") but it is **not present in this repo**.

**Stack:** Flutter 3.44.x, Dart (`^3.6.2` User app / `>=3.2.0 <4.0.0` Vendor app), Provider (state), GetIt (DI, `lib/di_container.dart`), Dio (networking), Firebase (Core/Messaging/Auth — project `meatlab-29f15`), `drift` (local SQLite response cache, User app only).

**For deep detail beyond this file**, see `xdocs/`:
- `mobile_apps.md` — full feature/state audit of both apps as received (pre-customization baseline)
- `blueprint_user_app.md` / `blueprint_vendor_app.md` — exhaustive per-feature-module inventory (57 modules / 36 modules) — the completeness checklist for deciding what to keep/cut
- `mobile_customization_log.md` — step-by-step change log for every customization made, each with verification evidence (screenshots, logs). **Read this before assuming why something is the way it is.**

## 2. Development setup

No `.env` files — config lives as Dart `const` values in `lib/utill/app_constants.dart` per app (already pointed at production, see below).

```bash
cd "User app"        # or "Vendor app"
flutter pub get
flutter run -d <device-id>      # `flutter devices` / `adb devices` to list targets
```

- `baseUrl` in both apps' `AppConstants` = `https://shop.meatsokogroup.com` (production — there is no separate staging backend in use).
- Firebase is already wired: `google-services.json` / `GoogleService-Info.plist` / `firebase_options.dart` are committed and correct (project `meatlab-29f15`). These files are legitimately meant to be committed — they're public client config, not secrets.
- No database, no migrations — all persistence is server-side (the Laravel backend) or a local response cache (`drift`, User app only, not user-facing data).

## 3. Architecture and conventions

Standard per-feature layout, repeated ~57 times (User app) / ~36 times (Vendor app):
```
lib/features/<name>/
  screens/        # UI
  widgets/        # feature-local widgets
  controllers/     # ChangeNotifier, registered with Provider
  domain/
    models/
    repositories/  # + *_interface.dart, impl talks to Dio
    services/
```
- DI: `lib/di_container.dart` (GetIt). State: `Provider`/`ChangeNotifier` per feature controller.
- API endpoints: string constants in `lib/utill/app_constants.dart` (e.g. `loginUri`, `categoriesUri`), consumed via `lib/data/datasource/remote/dio/dio_client.dart`.
- Shared UI primitives: `lib/common/basewidget/` (User app) — custom app bars, buttons, snackbars, the "not logged in" bottom sheet, shimmer placeholders, etc. Reuse these rather than one-off widgets.
- The **auction** feature (10 modules in User app, buyer + seller-create flows; 1 module in Vendor app) is real, wired, config-gated functionality — livestock/product bidding with entry fees and wallet payment. Not a demo stub; treat it as first-class.
- **Intentional-but-unusual:** `MainActivity.kt` in both apps now lives at a directory path matching its actual Kotlin `package` declaration (`com/meatsokogroup/user/`, `com/meatsokogroup/vendor/`). It previously did **not** (a leftover from the vendor's own earlier rebrand — package changed in `build.gradle.kts` without moving the file). If you ever change `applicationId`/`namespace` again, move this file too or the drift will recur.
- **Two independent version strings** exist for each app and must be kept in sync by hand — see Gotchas.

## 4. Current implementation status

**Complete and verified live** (see `mobile_customization_log.md` for evidence):
- Both apps connect to and load real data from production.
- Package/bundle identifiers renamed off `6valley`/`sixvalley` naming, matching across Android+iOS (previously mismatched).
- Dart package renamed (`flutter_sixvalley_ecommerce`→`user_app`, `sixvalley_vendor_app`→`vendor_app`).
- Firebase properly wired — both apps registered under one shared project, `main.dart` fixed to actually consume `DefaultFirebaseOptions.currentPlatform` (see Gotchas — this was broken by default).
- Display-name rebrand: "6Valley"/"6Valley Vendor" → "MeatSoko"/"MeatSoko Vendor" everywhere it's user-visible (manifest labels, iOS bundle name, notification channel name, splash text).
- App version reset to a fresh `1.0.0` lineage for both apps.
- User app's Categories screen restructured: was a left vertical sidebar + right detail pane, now a horizontal category strip pinned at the top + full-width detail panel below.

**In progress — fix applied, wants manual confirmation:**
- **Registration and login-session-persistence are confirmed working live** (2026-08-31): reproduced a full sign-up on a genuinely fresh emulator install with `adb logcat` capturing real Dio traffic — `POST /api/v1/auth/register` returned `200` with a valid JWT, the session persisted correctly (Home showed "Hello, Welcome / Test", profile screen matched the created customer). The original "auth is not working" report is **not** a request/backend/token-storage defect.
- **Real bug found instead, and fixed: the Sign-Out confirmation bottom sheet's buttons didn't respond to touch.** `LogoutCustomBottomSheetWidget` (`lib/features/more/widgets/logout_confirm_bottom_sheet_widget.dart`) was shown via `showModalBottomSheet`; tapping "Cancel"/"Sign Out" inside it did nothing (no request, no dismissal), while tapping the scrim or the hardware back button worked fine — meaning the `ModalBottomSheetRoute` path itself was swallowing taps on its own content. Ruled out first: network, the `TextButton`-based `CustomButton` specifically (a raw `GestureDetector` in the same spot failed identically), `useRootNavigator: true`, and `enableDrag: false`. **Fix (2026-09-01):** replaced the presentation mechanism entirely — `LogoutCustomBottomSheetWidget` now has a `static show(context)` that uses `showGeneralDialog` (with an explicit `Material` ancestor, since `showGeneralDialog` doesn't auto-wrap like `showModalBottomSheet` does) plus a manual `Align(bottomCenter)` + `SlideTransition` to keep the identical bottom-sheet visual. This was observed working live — logout requests firing, session clearing, landing on the login screen — across repeated test rounds, though the very last manual confirmation pass was handed off before a fully clean single-tap-to-outcome trace was captured. **Verify manually before treating this as fully closed.** Full bisection trail in `xdocs/mobile_customization_log.md` under "Investigation — Auth is not working".

**Not started:**
- App icons and splash screen still show default/6valley artwork, not MeatSoko branding.
- Facebook login: App ID is still the literal placeholder `YOUR_APP_ID` in both `strings.xml`/`Info.plist` — will not work until real credentials are set (or the feature is removed).
- **iOS does not currently build** — a Swift Package Manager / Firebase version conflict (`firebase_messaging` wants `firebase-ios-sdk` 12.17.0, resolution picks an incompatible 12.15.0+). Note `disable-swift-package-manager: true` is already set in `pubspec.yaml` and does **not** prevent this — root cause not fully diagnosed. Android is the only reliably testable platform right now.
- Vendor app's iOS Universal Links domain (`applinks:6valley-install.6amdev.xyz`) is a 6amTech-owned domain, not MeatSoko's — deep links tied to it won't resolve regardless of anything else fixed.
- The feature-by-feature curation pass against `blueprint_user_app.md`/`blueprint_vendor_app.md` (deciding what to keep, cut, or change per module — e.g. whether all five non-M-Pesa payment gateways currently wired are wanted) hasn't started.

## 5. Important decisions

- **Customize the existing 6valley codebase rather than rebuild from scratch.** The same team already successfully customized the sibling web/backend repo extensively (affiliate program, subscriptions, sponsored placements, M-Pesa, courier integration, AI shopping assistant — see that repo's own history) using this exact pattern. A rebuild would mean re-deriving complex working business logic (multi-vendor cart rules, auction bidding, dual wallet ledgers) from a spec instead of reusing tested code.
- **Split mobile apps into their own repo**, independent of the web/backend repo, for independent versioning/deployment.
- **One shared Firebase project** (`meatlab-29f15`) registering all 4 client apps (user-android, user-ios, vendor-android, vendor-ios), rather than a separate project per app — standard for one company running multiple client apps against one backend, and leaves room to register a future Deliveryman app the same way.
- **New identifiers based on the domain MeatSoko actually owns** (`meatsokogroup.com`) rather than the unverified `meatsoko.com` — `com.meatsokogroup.user` / `com.meatsokogroup.vendor`, deliberately identical across Android and iOS this time.
- **Fresh `1.0.0` version lineage** for both apps rather than continuing the vendor template's `16.3`-style numbering, since this is effectively a new release line for MeatSoko.

## 6. Current task / next steps

1. **Manually confirm the Sign-Out fix** (see §4) — log in, open the account screen, tap the logout icon, tap "Sign Out" in the sheet that appears, and confirm it actually signs out (lands on the login screen) and that "Cancel" correctly dismisses without signing out. If it's still flaky, the root cause of the original `showModalBottomSheet` failure was never pinned down (see the bisection trail in `xdocs/mobile_customization_log.md`) — worth checking whether the other ~17 `showModalBottomSheet` call sites in `more_screen_view_new.dart` have the same underlying issue, since this fix only touched the logout one.
2. App icons + splash screen artwork.
3. Facebook App ID — get real credentials or remove the feature.
4. Diagnose and fix the iOS Swift Package Manager build failure.
5. Feature curation pass against the blueprint docs.

## 7. Gotchas

- **Two independent version strings per app** — `pubspec.yaml`'s `version:` (drives store metadata) and `AppConstants.appVersion` (drives the in-app forced-update check against a server-configured minimum). Nothing keeps them in sync automatically. Also: the **server-side** minimum-version gate (Admin → System Setup → App Settings; `business_settings` keys `user_app_version_control` / `seller_app_version_control`) must be kept ≤ the app's actual version or **every user gets walled into an unusable update screen** — this already happened once and was fixed manually on production.
- **The splash screen caches `/api/v1/config` locally** (via `drift`) for instant routing on repeat app opens, and checks that cached copy *before* the fresh network response arrives. A device that had the app open before a server-side config change (e.g. the version gate above) can still show the old behavior for one more launch even after the server is fixed. Uninstall/reinstall (or clear app storage) to force a clean cache when debugging anything config-driven.
- **`flutterfire configure` does not fully wire itself up.** It correctly registers apps and generates `lib/firebase_options.dart`, but does not (at least didn't here) update `main.dart` to use it, and doesn't reliably refresh the native `GoogleService-Info.plist` on iOS. Always verify `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` is actually what's called — both apps originally had dead placeholder init code that silently fell back to reading native config directly.
- **`flutter analyze` scans the whole project tree, not just `lib/`.** A stray outdated duplicate directory once existed at the User app's root (`push_notification/`, `localization/`, dead code never imported by anything) and produced ~124 confusing false-positive-looking errors. If analyze ever reports errors referencing content that doesn't match what's actually in `lib/`, check for stray duplicate files elsewhere before assuming the real code is broken.
- iOS currently doesn't build at all (see §4) — don't treat a clean `flutter analyze` as proof the app builds on iOS.
- `google-services.json` / `GoogleService-Info.plist` are supposed to be committed — don't add them to `.gitignore`.

## 8. Useful commands

```bash
# From "User app/" or "Vendor app/":
flutter pub get
flutter run -d <device-id>
flutter analyze --no-fatal-infos
flutter test                        # exists but is only the unmodified Flutter-scaffold
                                     # smoke test — no real coverage yet

# Device/emulator
adb devices                         # list connected Android devices/emulators
flutter devices

# Live debugging — most useful tool used throughout this project's history;
# DioClient logs full request/response bodies including error responses
adb logcat -d --pid=$(adb shell pidof com.meatsokogroup.user)
adb logcat -d --pid=$(adb shell pidof com.meatsokogroup.vendor)

# Backend health check (production)
curl https://shop.meatsokogroup.com/api/v1/config
```
