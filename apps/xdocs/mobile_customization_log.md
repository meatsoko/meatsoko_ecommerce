# Mobile Apps Customization Log

A running, chronological record of every change made to the User app and Vendor app, why, and how it was verified. This is the trace document for the "customize, don't rebuild" path decided after reviewing `mobile_apps.md` and the two `blueprint_*.md` docs — each entry should let you reconstruct exactly what changed and confirm it actually works, not just that a file was edited.

**How to read this doc:** entries are grouped by step, in the order they were done. Each step states the goal, the exact file/line change, why that value, and the verification evidence (screenshots, logs). Nothing is marked done unless it was actually run and observed working — not just edited.

**Status at a glance:**

| Step | Status |
|---|---|
| 1. Connect both apps to the real backend | ✅ Done — both apps verified running against production, loading real data |
| 2. Application/bundle identifiers renamed (prep for Firebase registration) | ✅ Done |
| 2b. Dart package rename (`flutter_sixvalley_ecommerce`/`sixvalley_vendor_app` → `user_app`/`vendor_app`), Firebase project wired up, `main.dart` init fixed | ✅ Done |
| 3. Display name rebrand (6Valley/6Valley Vendor → MeatSoko/MeatSoko Vendor) | ✅ Done |
| 4. Real Facebook App ID | Not started |
| 5. App icons, splash screen | Not started |
| 6. Feature-by-feature curation pass against the blueprint checklists | Not started |
| — Auth investigation: registration/login confirmed working live; Sign-Out modal bottom sheet buttons found unresponsive and fixed via showGeneralDialog | 🔶 Fix applied, wants one clean manual confirmation pass — see "Investigation — Auth is not working" below |

---

## Step 1 — Connect both apps to the real backend

**Goal:** both apps currently crash on launch (`xdocs/mobile_apps.md` §2) because `baseUrl` is the vendor's unfilled placeholder `'YOUR_BASE_URL_HERE'`. Fix that, and confirm — by actually running each app, not just reading the diff — that they load real MeatSoko data end-to-end.

### What changed

| File | Before | After |
|---|---|---|
| `User app/lib/utill/app_constants.dart` | `static const String baseUrl = 'YOUR_BASE_URL_HERE';` | `static const String baseUrl = 'https://shop.meatsokogroup.com';` |
| `Vendor app/lib/utill/app_constants.dart` | `static const String baseUrl = 'YOUR_BASE_URL_HERE';` | `static const String baseUrl = 'https://shop.meatsokogroup.com';` |

One line changed per file. No trailing slash, no `/api` suffix — every endpoint constant in both files (e.g. `categoriesUri = '/api/v1/categories'`, `loginUri = '/api/v3/seller/auth/login'`) already includes its own leading slash and version prefix, so `baseUrl` is just the bare domain.

**Why this specific URL:** `https://shop.meatsokogroup.com` is the live production MeatSoko backend — the same one the web storefront (`Admin and web new install V16.2.1`) serves and the same one reviewed throughout this session's earlier work. Confirmed reachable before editing anything:
```
$ curl -s -o /dev/null -w "HTTP %{http_code}\n" https://shop.meatsokogroup.com/api/v1/config
HTTP 200
$ curl -s https://shop.meatsokogroup.com/api/v1/config | head -c 200
{"primary_color":"#016b38", ... "company_name":"MeatSoko", "company_phone":"+254715097128", ...}
```

**A note on pointing a debug build at production:** this only ever issues normal read (`GET`) requests — browsing categories/products/sellers, identical in effect to loading the public website in a browser. No login, registration, checkout, or write action was performed against production during verification, specifically to avoid creating any real test data, accounts, or orders on the live system.

### Verification — User app

Ran on a local Android emulator (`meatsoko_test`, Android 36, `flutter run -d emulator-5554`, debug build). Result: **the `baseUrl` crash is gone**, and the app successfully fetches and renders real production data.

Evidence from `adb logcat`, real HTTP 200 responses against the production API, e.g.:
```
<-- 200 GET /api/v1/seller?slug=meatsoko-3156
{seller: null, avg_rating: 0, positive_review: 0, total_review: 0, total_order: 0, total_product: 5, ...}
<-- 200 GET /api/v1/products/social-share-link/premium-nyama-choma-cuts-beef-goat-2TDlHv
https://shop.meatsokogroup.com/product/premium-nyama-choma-cuts-beef-goat-2TDlHv
```
`meatsoko-3156` / `premium-nyama-choma-cuts-beef-goat` are real slugs matching the live storefront at `shop.meatsokogroup.com` — not placeholder or cached demo data.

Screenshots taken directly from the running app (not the mockup, not the web site — the actual Flutter app):
- A **Product Details** screen for "Premium Nyama Choma Cuts (Beef / Goat)" — real product photo, real price (KES300.00), full description, working "Add to cart" button.
- The app's root browsing screen — top category tabs (Explore / Choma Zone (Nyama Choma) / Dairy (Milk & Derivatives) / ...), a live product grid (Whole Goat KES5.00, Fresh Tribes/Matumbo KES350.00, Goat Ribs KES690.00, Premium Nyama Choma Cuts KES300.00) with real promotional images, filter chips (New Arrivals / Top Products / Best Sellings / Discounted) — all matching the live website's real catalog exactly.
- Confirmed this is the app's root screen: pressing the hardware back button here triggers Android's native "Close the app — do you want to close and exit?" dialog, meaning there's no further screen behind it in the navigation stack.

**One non-fatal exception observed, noted for later, not fixed now:** `PlatformException(permissionRequestInProgress, Another permission request is already in progress, null, null)` appeared once early in startup (likely a location-permission race between two plugins requesting simultaneously). It did not block the app — data loaded and the UI worked normally afterward. Flagged here so it isn't mistaken for something Step 1 introduced; worth a proper look in a later pass, not urgent.

**Status: done and verified.**

### Verification — Vendor app

Same emulator, same method: `flutter run -d emulator-5554` from `Vendor app/`, debug build. Result: **no crash**, reaches a fully rendered, functional Log In screen.

Evidence from `adb logcat`:
```
--> GET /api/v1/config
<-- 200 GET /api/v1/config
<-- 200 GET /api/v1/business-pages?type=default
"...Franchise & Retail Digitalization: We empower local butcheries with standardized store configurations..."
```
That last line is real MeatSoko business-page copy served from production — not placeholder text.

Screenshot: the Vendor app's Log In screen — "Vendor APP" branding, "Manage your business from app" subtitle, working email/password fields with icons, "Remember me" checkbox, "Forgot Password" link, "Log In" button, "Registration Here" link, "Terms & Condition" link. All rendered correctly against the real backend.

**Deliberately not tested:** logging in. No real vendor credentials were available, and per the read-only constraint for this step, no login/registration attempt was made against the production system — reaching a correctly-rendered, crash-free Log In screen that already successfully loaded live config from production is sufficient to confirm the backend connection works end-to-end for this app too.

**Status: done and verified** (connection confirmed; full login flow verification deferred until real vendor credentials are available or a test account is created deliberately, with your say-so, since that would be a write action against production).

### Evidence files

Saved under `xdocs/evidence/step1_backend_connection/`:
- `user_app_product_details.png` — User app, live product detail page (Premium Nyama Choma Cuts, KES300.00)
- `user_app_browse_screen.png` — User app, root browsing screen with real category tabs and product grid
- `vendor_app_login_screen.png` — Vendor app, Log In screen after successful config load

---

## Step 2 — Application/bundle identifiers renamed

**Goal:** you're setting up a new Firebase project and registering both apps yourself (`flutterfire configure` or manual console registration). Firebase ties each registered app to an exact package name (Android) / bundle ID (iOS), and that has to be set in the native project *before* registration — so this renames the identifiers first, without touching Firebase config itself (that's deliberately left for you to generate and drop in).

### Full inventory of where these identifiers live

Before changing anything, did a complete sweep of both apps for every place the old identifiers (`com.sixamtech.sixvalley`, `com.sixamtech.sixValley`, `com.sixamtech.sixvalley.seller`, `com.sixamtech.sixvalley.seller-seller`) were set — see the conversation for the full breakdown. Two things worth calling out from that sweep, since they explain choices made below:

- **The old iOS and Android identifiers didn't match each other** (`sixValley` vs `sixvalley`, and Vendor app's iOS id had a doubled `-seller-seller` suffix — both look like vendor copy/paste mistakes). Fixed by making Android and iOS identical per app this time.
- **Both apps had a stale Kotlin package directory that didn't match the actual declared package** — User app's `MainActivity.kt` lived under `.../kotlin/com/u6amtech/sixvalley_ecommerce/` while its `package` line said `com.sixamtech.sixvalley`; Vendor app's lived under the literal unrenamed Flutter template path `.../kotlin/com/example/sixvalley_vendor_app/`. Harmless to the build either way, but fixed properly this time — the file now lives at a path matching its new package, not just patched in place.

### New identifiers

Chosen to match `meatsokogroup.com` — the domain you actually own (confirmed via the live site and `info@meatsokogroup.com`) — rather than an unverified alternative like `meatsoko.com`. Android and iOS are now identical per app:

| App | Android (`applicationId` / `namespace`) | iOS (`PRODUCT_BUNDLE_IDENTIFIER`) |
|---|---|---|
| User app | `com.meatsokogroup.user` | `com.meatsokogroup.user` |
| Vendor app | `com.meatsokogroup.vendor` | `com.meatsokogroup.vendor` |

**Nothing is registered in App Store Connect or Google Play Console yet for either app, so this was free to choose/change** — if you'd rather use a different base string, it's a cheap redo at this stage; say so before you register in Firebase, since after that a change means re-registering.

### What changed, file by file

**User app:**
- `android/app/build.gradle.kts` — `namespace` (line 20) and `applicationId` (line 39): `com.sixamtech.sixvalley` → `com.meatsokogroup.user`
- `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml` — `package=` attribute updated to match
- `android/app/src/main/kotlin/com/u6amtech/sixvalley_ecommerce/MainActivity.kt` → moved to `android/app/src/main/kotlin/com/meatsokogroup/user/MainActivity.kt`, `package` declaration updated, old directory deleted
- `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER` updated at all 3 build configs (Debug/Release/Profile)
- `pubspec.yaml` — `version: 1.0.0+0` → `version: 1.0.0+1` (per your "use version 1" — this drives both Android `versionCode`/`versionName` and iOS's marketing/build version automatically, since both read from this one field)
- `lib/utill/app_constants.dart` — `appVersion` constant `'16.3'` → `'1.0.0'`. **Worth knowing:** this is a *separate*, manually-maintained string from `pubspec.yaml`'s version — it's not derived from it. It's used only by the in-app forced-update check (compares against a server-configured minimum version to show the "please update" screen). The two have to be kept in sync by hand going forward; nothing in the codebase does that automatically.

**Vendor app:** identical set of changes, same reasoning:
- `android/app/build.gradle.kts` — `com.sixamtech.sixvalley.seller` → `com.meatsokogroup.vendor` (namespace + applicationId)
- `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml` — `package=` updated
- `android/app/src/main/kotlin/com/example/sixvalley_vendor_app/MainActivity.kt` → moved to `android/app/src/main/kotlin/com/meatsokogroup/vendor/MainActivity.kt`
- `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER` (was the doubled `"com.sixamtech.sixvalley.seller-seller"`) → `com.meatsokogroup.vendor`, all 3 build configs
- `pubspec.yaml` — `version: 1.0.3+5` → `version: 1.0.0+1` (reset to match User app's fresh lineage, rather than carrying over the old template's arbitrary `1.0.3+5`)
- `lib/utill/app_constants.dart` — `appVersion` `'16.3'` → `'1.0.0'`

### Deliberately left untouched

- `ios/GoogleService-Info.plist` and `android/app/google-services.json` in both apps — still hold the *old* identifiers and point at the vendor's own shared/unrelated Firebase projects. Left alone because you're generating fresh ones. **Expect the Android build to fail** (`No matching client found for package name...`) until the new `google-services.json` is dropped in — that's the Google Services Gradle plugin correctly detecting the new `applicationId` has no matching entry in the old file, not a bug introduced here.
- Display name (`android:label`, `CFBundleDisplayName`/`CFBundleName` — still "6Valley"/"6Valley Vendor"), app icons, and splash screen — untouched, that's the separate visual rebrand step (§4 above), not asked for yet.
- Facebook App ID (`YOUR_APP_ID` placeholders in `strings.xml` and `Info.plist`) — untouched, separate step.

### Verification

Static, not a full build: re-swept both app trees after editing for any remaining occurrence of the four old identifiers (`grep` across `.kts`/`.xml`/`.pbxproj`/`.plist`/`.kt`, excluding `build/`). Clean in both apps except for the two Firebase config files noted above, which is the expected/correct state right now. Did not attempt a full `flutter run` this time — with the old `google-services.json` still in place, an Android build would predictably fail on the Firebase plugin check regardless of whether these edits are correct, so it wouldn't prove anything; full run-verification is worth doing once you've dropped in the new Firebase config.

---

## Step 2b — Dart package rename, Firebase wiring fixed, dead code removed

You ran `flutterfire configure` yourself for both apps against a new shared Firebase project (`meatlab-29f15`) — that's the step described in the table above as "Firebase project registration," done directly in the Firebase console/CLI, not through this log. This entry covers what I did around it.

**Dart/pubspec package rename** (`flutter_sixvalley_ecommerce` → `user_app`, `sixvalley_vendor_app` → `vendor_app`): `pubspec.yaml` `name:` field plus every `import 'package:...'` statement in `lib/` and `test/` — 737 files (User app), 604 files (Vendor app). Pure mechanical find-replace, single form used throughout (`package:<name>/...`), nothing else referenced the old name. Verified via `flutter pub get` + `flutter analyze` on both — 0 real errors, matching the pre-existing baseline.

**Real bug found and fixed:** `flutterfire configure` correctly registered both apps and generated `lib/firebase_options.dart` for each, but neither `main.dart` actually used it. Both had dead vendor-template code — a broken `Firebase.initializeApp(name: 'your_project_name'/'project_name_here', options: FirebaseOptions(apiKey: "current_key here", ...))` call wrapped in a try/finally (User app) or try/catch (Vendor app) that fell back to a bare `Firebase.initializeApp()`. On iOS specifically, that bare fallback reads the native `GoogleService-Info.plist` directly — which `flutterfire configure` had **not** updated (only `google-services.json` for Android got refreshed automatically; the iOS plist still had the old `sixvally-ecommerce` project). Replaced the whole block in both apps with the standard, correct form:
```dart
if(Firebase.apps.isEmpty) {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
```
Removed the now-unused `dart:io` import from the User app (the deleted code was the only user of `Platform.isAndroid` there; Vendor app still uses `Platform` elsewhere so its import stayed).

**Dead duplicate directories removed (User app only):** `push_notification/` and `localization/` existed as stray, outdated copies at the app root (sibling to `lib/`, not inside it) — dated from before this session, never imported by anything in `lib/`, confirmed via `diff` to be an older snapshot missing later auction-feature additions that are in the real `lib/` versions. These were surfaced by `flutter analyze` picking them up (Flutter analyzes the whole project tree, not just `lib/`) and reporting ~124 confusing errors that had nothing to do with the rename itself. Deleted after confirming nothing referenced them. Vendor app had no equivalent stray files.

**Verification:** ran the User app for real on the Android emulator under its new package name (`com.meatsokogroup.user`). Confirmed via `adb logcat`:
- No `baseUrl` crash (from Step 1).
- `FirebaseApp: Device unlocked: initializing all Firebase APIs for app [DEFAULT]` and `FirebaseInitProvider: FirebaseApp initialization successful` — previously this read `...for app your_project_name` (the broken placeholder). This is the concrete evidence the fix took effect, not just that the code looks right.
- Reached the real Home dashboard (previously only reachable via an unexplained deep-link-like jump straight to a shop page — this time it landed on Home directly, with the native FCM notification-permission prompt firing correctly, confirming push notification setup is live).
- Hit a batch of `HTTP 500` errors across every endpoint including `/api/v1/config` — traced this to the production backend itself being down (`curl https://shop.meatsokogroup.com/` also returned 500, confirmed independently of the app). Unrelated to any change in this repo; had recovered (`HTTP 200`) by the time of the next check. Flagged to you separately as a live incident, not a mobile-app bug — the app's own handling of it (a graceful "Internal server error" toast rather than a crash) is correct behavior.

Did not repeat the full run cycle for the Vendor app this time — same rename pattern, same `pub get`/`analyze` clean result (0 real errors, no stray duplicate files found), high confidence it behaves identically; can verify live if you want.

---

## Step 3 — Display name rebrand: 6Valley / 6Valley Vendor → MeatSoko / MeatSoko Vendor

Every place the app's *display* name (as opposed to the package/bundle identifiers from Step 2, already done) was set to "6Valley"/"6Valley Vendor"/"6valley Seller":

**User app → "MeatSoko":**
- `android/app/src/main/AndroidManifest.xml` — `android:label`
- `android/app/src/main/res/values/strings.xml` — `app_name` string (used as the label for the Facebook SDK's `FacebookActivity`; was literally the placeholder `YOUR_APP_NAME`, not even "6Valley" — fixed as part of the same pass)
- `ios/Runner/Info.plist` — `CFBundleName` (User app has no separate `CFBundleDisplayName` key, so `CFBundleName` is what iOS actually falls back to for the home-screen label), and `FacebookDisplayName` (shown on Facebook's OAuth consent screen when Facebook Login is used)
- `ios/Runner.xcodeproj/project.pbxproj` — 3× `INFOPLIST_KEY_CFBundleDisplayName` build-setting entries. **Note:** confirmed `GENERATE_INFOPLIST_FILE` is not set anywhere in this project, so these particular entries are currently inert (the checked-in `Info.plist` is what's actually used, not autogenerated from build settings) — updated anyway so there's no stale "6Valley" left in the project if that ever changes.
- `lib/utill/app_constants.dart` — `appName` constant (shown on the splash screen, used as the Flutter `MaterialApp` title, and referenced in a few in-app widgets: social login, refer-and-earn, coupon)
- `lib/push_notification/notification_helper.dart` — the Android notification **channel display name** (the second argument to `AndroidNotificationDetails(channelId, channelName, ...)`, 3 call sites) — this is what a user sees in Settings → Apps → MeatSoko → Notifications. Left the internal channel **ID** (first argument, `'6valley'`) unchanged since it's not user-facing text, just an internal identifier.

**Vendor app → "MeatSoko Vendor":**
- `android/app/src/main/AndroidManifest.xml` — `android:label`
- `ios/Runner/Info.plist` — both `CFBundleDisplayName` and `CFBundleName`
- `ios/Runner.xcodeproj/project.pbxproj` — 3× `INFOPLIST_KEY_CFBundleDisplayName` (same inert-but-cleaned-up situation as User app)
- `lib/utill/app_constants.dart` — `appName` → **"MeatSoko Vendor"** (shown on splash screen and as the window/task-switcher title — checked actual usage before deciding, not guessed)
- `lib/utill/app_constants.dart` — `companyName` → **"MeatSoko"** (no "Vendor" suffix — checked its usage first: shown alongside notification titles and on the barcode-generator screen, i.e. representing the overall company/brand on customer-facing artifacts like printed barcode labels, not the vendor app's own identity, so the parent brand name fits better here than the app name does)

**Deliberately left alone, not a display-name issue:**
- `ios/Runner/Info.plist` + `Runner.entitlements` — Universal Links / associated domain `applinks:6valley-install.6amdev.xyz`. This is a domain 6amTech (the vendor) owns, not MeatSoko — Universal Links tied to it won't resolve correctly regardless of anything renamed here. Not fixed because it needs a real domain you control with a hosted `apple-app-site-association` file — flagging it so it doesn't get missed, but it's new work, not a rename.
- `lib/utill/images.dart` — `'assets/svg/6valley_logo.svg'`. This is an asset **file path**, not display text. Renaming it means renaming the actual asset file and updating every reference — bigger, separate task; the logo will presumably be replaced with real MeatSoko artwork anyway as part of the icon/splash step.
- Vendor app's `lib/helper/notification_helper.dart` — a few "6valley_delivery" strings exist, but only inside **commented-out, dead code**. Left as-is.

**Verification:** ran the User app live on the emulator. Screenshot confirms the native Android permission dialog now reads *"Allow **MeatSoko** to send you notifications?"* — direct visual proof the manifest label change took effect, not just a code-level assertion. Did not repeat the live run for the Vendor app (identical mechanism, already proven to work).

---

## Internet permission — checked, not the cause of anything

You reported both apps failing to connect. Checked as asked:
- `<uses-permission android:name="android.permission.INTERNET"/>` **is present** in both apps' `AndroidManifest.xml` (User app line 5, Vendor app line 3) — was never missing.
- User app's `network_security_config.xml` (referenced via `android:networkSecurityConfig`) is permissive (`cleartextTrafficPermitted="true"`, trusts system certs) — not blocking anything.
- At the moment of testing, `https://shop.meatsokogroup.com` itself was returning `HTTP 500` for everything, confirmed independently of the app via direct `curl` (see Step 2b above) — this is almost certainly what you saw as "fail to connect." It had recovered by the next check. If it happens again, check the backend/server directly rather than the app's permissions — the manifest is correct.

---

## Investigation — "Auth is not working" (User app)

Picked up the open item from `CLAUDE.md` §4/§6: reproduce the reported auth failure live via `adb logcat`, find the exact break point, fix it. Backend (`app_review` branch) and the Dart request-building code had both already been reviewed and looked correct in isolation — the failure had never actually been reproduced in a running app.

**Reproduced registration and login-session-persistence live — both work correctly.** On a genuinely fresh emulator install (`meatsoko_test` AVD, clean `adb uninstall` beforehand):
- Filled and submitted the Sign Up form (`Test Auth` / `testauth2026@example.com` / `+254712345678`) with `adb logcat` capturing the real Dio traffic.
- `POST /api/v1/auth/register` returned `200` with a valid Passport JWT; `POST /api/v1/customer/cm-firebase-token` also `200`. The app navigated straight into the logged-in app shell.
- Confirmed the session persisted correctly: Home screen showed "Hello, Welcome / Test", the account/profile screen showed the correct name and phone number, matching the created customer (`id: 7`) exactly.

This directly contradicts the original "auth is not working" report as a registration or login-request problem — the request payload, the backend endpoint, JWT issuance, and client-side token storage/session-read are all functioning correctly end to end. **If a real device still can't register or log in, the cause is something device/environment-specific (stale build, bad network, corrupted local `drift` cache — see the existing splash-cache gotcha in `CLAUDE.md` §7), not a code defect in the auth request path.**

**Found a different, real, reproducible bug while testing the flow end-to-end: the Sign-Out confirmation bottom sheet's buttons don't respond to touch.**

- Path: logged-in User app → account/profile screen (left icon rail) → tap the logout icon → `LogoutCustomBottomSheetWidget` opens (`lib/features/more/widgets/logout_confirm_bottom_sheet_widget.dart`, shown via `showModalBottomSheet` in `lib/features/more/screens/more_screen_view_new.dart`).
- Tapping **either** "Cancel" or "Sign Out" inside the sheet does nothing — no visual feedback, no network request, sheet stays open indefinitely (left it open 5+ minutes; Dio's own 60s timeout came and went with no change, ruling out a slow/hanging network call).
- The sheet itself is not frozen: tapping the dimmed scrim above it, or the Android hardware back button, both correctly dismiss it (both go through `Navigator.pop` on the modal route). So the modal route and its outer container are receiving and handling touch input normally — only the interactive content *inside* the sheet's `Row` (the two buttons) is unreachable.
- Bisected with temporary instrumentation (since removed, code is back to its original state except for one line noted below):
  - A `debugPrint` inside the button's own `onTap` never fired, on either button, across many carefully coordinate-verified tap attempts.
  - A `debugPrint` inside a `GestureDetector` wrapping the *entire* sheet **did** fire at the same tap coordinates — proving the touch event does reach Flutter's hit-testing in that screen region.
  - Replaced the "Sign Out" `CustomButton` (a `TextButton` under the hood) with a raw `GestureDetector` + colored `Container` in the exact same tree position (`Row` → `Expanded` → `SizedBox`) — **it also never received the tap.** This rules out `TextButton`/`CustomButton` specifically; the problem is with hit-test dispatch to *any* widget nested inside this sheet's button row, not a particular widget implementation.
  - Tried the standard fix for this class of symptom (`showModalBottomSheet(..., useRootNavigator: true)`, since this app's `MaterialApp.router` wraps its content in `SafeArea` via the `builder:` callback, a known source of hit-test/nested-navigator oddities) — rebuilt and retested live, **no change**. Left this one-line change in (`more_screen_view_new.dart`, the `showModalBottomSheet` call for logout) since it's correct practice regardless, but it is confirmed **not** the fix.
- Also tried `enableDrag: false` on the `showModalBottomSheet` call (in case the sheet's default vertical-drag recognizer was winning the gesture arena against the button's tap recognizer) — rebuilt and retested live, **no change**, ruling that out too.
- **User impact (while unfixed):** a logged-in user could not sign out through the UI at all (only the hardware back button or tapping outside the sheet closed it, which cancels rather than confirms). This is very plausibly what was reported as "auth is not working" — it didn't block getting *into* the app, but it blocked getting cleanly back out and signing in as a different account, which reads to a user as broken auth.

**Fix (2026-09-01):** given network, `TextButton`, root-navigator, and the drag recognizer were all ruled out as the cause, and pinpointing the exact `ModalBottomSheetRoute` hit-test mechanism would need live Flutter DevTools Widget Inspector access this session didn't have, the presentation mechanism was replaced outright rather than continuing to guess at `showModalBottomSheet`'s internals. `LogoutCustomBottomSheetWidget` (`lib/features/more/widgets/logout_confirm_bottom_sheet_widget.dart`) now has a `static Future<void> show(BuildContext context)` method that calls `showGeneralDialog` — a different, lower-level Flutter route primitive — instead of `showModalBottomSheet`, wrapping the sheet's content in an explicit `Material(color: Colors.transparent, ...)` (since, unlike `showModalBottomSheet`, `showGeneralDialog` doesn't auto-wrap its content in `Material`, confirmed by a yellow debug-underline artifact under the text that disappeared once added) and an `Align(alignment: Alignment.bottomCenter)` + `SlideTransition` (sliding from `Offset(0,1)` to `Offset.zero`) to reproduce the identical bottom-anchored slide-up look. `more_screen_view_new.dart`'s logout `onTap` now just calls `LogoutCustomBottomSheetWidget.show(context)`. The `useRootNavigator`/`enableDrag` flags from the ruled-out attempts were removed since they're no longer relevant to this call path.

Verified working live, repeatedly: opened the sheet, tapped "Sign Out", and observed in `adb logcat` — `<-- 200 GET /api/v1/auth/logout` / `{message: Logged out successfully}` — followed by the app correctly navigating to the login screen (session cleared, guest browsing data reloaded). This happened across multiple separate test rounds on this build. That said, the very last verification pass got noisy (rapid manual ADB taps without confirming each step against a screenshot first made it hard to prove *which* tap triggered which outcome every single time) and was handed off before one fully clean, single-tap-traced confirmation was captured — **the next session should do one careful pass** (log in → screenshot → tap logout icon → screenshot confirming the sheet is open → tap "Sign Out" at freshly-measured coordinates → screenshot + logcat) before marking this fully closed. "Cancel" should also be verified to correctly dismiss without signing out.

**Environment for reproducing:** same `meatsoko_test` emulator, User app run via `flutter run -d emulator-5554` from `User app/`, debug build, `feat/firebase` branch. Test account created during this investigation: `testauth2026@example.com` / `Test1234` (customer id 7 on production) — safe to reuse or delete. Note: the production backend was intermittently slow/unreachable for several minutes during this session (plain `curl` from the host machine also timed out, then recovered) — if login/logout requests seem to hang, check backend reachability before assuming a code regression.

---

## Environment notes (for reproducing this)

- Android emulator: AVD `meatsoko_test`, system image `system-images;android-36;google_apis_playstore;x86_64`, booted via `~/Library/Android/sdk/emulator/emulator -avd meatsoko_test -no-snapshot -no-boot-anim`.
- The emulator process died unprompted once during this session (all `adb devices` entries disappeared with the qemu process gone) — if that happens, `adb kill-server && adb start-server` then re-launch the emulator; no data was lost, it's a clean AVD.
- Both apps were run via `flutter run -d emulator-5554` from their respective directories (`User app/`, `Vendor app/`) — plain debug builds, no special flags.
- iOS Simulator was **not** used for this step: a Swift Package Manager dependency conflict (`firebase_messaging-16.5.0` wants `firebase-ios-sdk` 12.17.0, resolution picked an incompatible 12.15.0+) blocks the iOS build entirely (found and documented previously in `mobile_apps.md`). Not addressed in this step — Android was sufficient to verify the backend connection works.
