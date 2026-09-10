# Play Store Readiness — User App

**Last updated:** 2026-09-10 · **Scope:** `user_app`, Android only (iOS still doesn't build — see `gap_audit_2026-09-07.md` §D.1)
**Verified by:** direct inspection of the manifest, Gradle config, keystore, and icon assets, plus live checks against production.

## Status: 1 blocker left (was 5)

| # | Blocker | Status |
|---|---------|--------|
| 1 | Release signing keystore | ✅ Done |
| 2 | Google Maps API key | ✅ Done |
| 3 | Privacy policy URL | ✅ Done |
| 4 | App Links | ✅ Done — verified live |
| 5 | **App icon** | ❌ **Open** |

---

## Remaining blocker

### 5. App icon is still the 6valley template artwork

`android/app/src/main/res/mipmap-*/ic_launcher.png` is unchanged (verified visually — generic blue hexagon + shopping cart). No `mipmap-anydpi-v26/`, so no adaptive icon either; Play's pre-launch report flags this and it looks dated on Android 8+.

Note `user_app/pubspec.yaml` has **no** `icons_launcher`/`flutter_icons` config (that's only in `vendor_app`), and no source icon exists at `assets/images/ic_launcher.png`. So this needs the config added plus a real MeatSoko source icon before a generator can run.

### 5. App icon is still the 6valley template artwork

`android/app/src/main/res/mipmap-*/ic_launcher.png` is unchanged (verified visually — generic blue hexagon + shopping cart). No `mipmap-anydpi-v26/`, so no adaptive icon either; Play's pre-launch report flags this and it looks dated on Android 8+.

Note `user_app/pubspec.yaml` has **no** `icons_launcher`/`flutter_icons` config (that's only in `vendor_app`), and no source icon exists at `assets/images/ic_launcher.png`. So this needs the config added plus a real MeatSoko source icon before a generator can run.

---

## Resolved since last review

**4. App Links** — verified live 2026-09-10:

- `AndroidManifest.xml:85` → `<data android:host="shop.meatsokogroup.com"/>` in the `autoVerify="true"` intent-filter. No App Links placeholders remain in `android/`.
- `https://shop.meatsokogroup.com/.well-known/assetlinks.json` serves valid JSON as `application/json`, with `com.meatsokogroup.user` and the production SHA-256, relation `delegate_permission/common.handle_all_urls` intact. The `/public/` copy matches (its old `com.sixamtech.sixvalley` values are gone).
- **Google's Digital Asset Links API confirms the statement resolves with `errorCode: none`** — the authoritative check Android performs.

Deep links (`/product/…`, `/vendor-shop/…`, `/track-order`, `/referral-login`, `/auction/product/…`) should now open the app once a build signed with this cert is installed.

> **Play App Signing:** only the upload cert's fingerprint is listed. If you enroll (default for new apps), Google re-signs with *its* key and that's what devices check — add the fingerprint from Play Console → Setup → App signing alongside the existing one, or verification breaks for Play installs while continuing to work for local/sideloaded builds.
>
> Serving note: the vhost document root is the project root, not `public/`, so the file served is the **root** `.well-known/assetlinks.json`. Keep both copies in sync when redeploying.

**1. Release signing** — `android/key.properties` present and correctly gitignored; keystore at `/Users/mac/upload-keystore.jks` (alias `upload`, valid to 2054); `build.gradle.kts:56` now points the release build at `signingConfigs.getByName("release")` instead of the debug config.

> ⚠️ `storeFile` is an absolute path into your home directory, so release builds only work on this machine. Fine for now; needs a relative path or CI secret before anyone else builds a release. **Back up the keystore and its passwords off this machine** — losing them means never being able to update this listing again.

**2. Maps API key** — real key now in `AndroidManifest.xml:45`. Confirm in Google Cloud Console that it's restricted to package `com.meatsokogroup.user` + the SHA-1 `E9:2E:75:5C:5C:D3:DF:71:B4:E9:F7:2E:CD:D2:B6:55:05:F6:A2:98` (can't verify restrictions from here).

**3. Privacy policy** — both pages live and returning HTTP 200:
- `https://shop.meatsokogroup.com/business-page/privacy-policy`
- `https://shop.meatsokogroup.com/business-page/terms-and-conditions`

Content is also bundled in-app (`privacy_policy_screen.dart`, `terms_and_conditions_screen.dart`), so it renders even if the backend is unreachable. Use the privacy-policy URL in the Play Console listing.

> Minor: `config.privacy_policy` is still `null` in the production API. Harmless now that the app bundles the text, but worth setting in Admin → System Setup for the web storefront's sake.

---

## Should fix before submitting (non-blocking)

1. **Facebook placeholders** — `strings.xml:3,5` still ship `YOUR_APP_ID` and instructional filler text. Safe at runtime (the login button is force-disabled in `only_social_login_widget.dart:65-71`), but it's a fragile override over broken config. Get real credentials or cut the feature and drop `flutter_facebook_auth`.
2. **Cleartext traffic allowed globally** — `network_security_config.xml:3` sets `cleartextTrafficPermitted="true"` for all domains. The app's `baseUrl` is already HTTPS, so this is pure attack surface. Set it `false` and scope an exception only if a local dev host needs it.
3. **No shrinking or obfuscation** — no `minifyEnabled`/`shrinkResources`/ProGuard rules in the release block. Bigger APK, zero obfuscation. Needs testing when enabled (reflection-heavy plugins need keep rules).
4. **No crash reporting** — no `firebase_crashlytics` in `pubspec.yaml`. Firebase Core is already wired (`meatlab-29f15`), so this is a small add. Without it, you learn about crashes from user complaints.
5. **Permissions hygiene** — `READ/WRITE_EXTERNAL_STORAGE` and `BLUETOOTH`/`BLUETOOTH_ADMIN` have no `maxSdkVersion` caps against `targetSdk = 36`; `requestLegacyExternalStorage` is dead config past API 29. The OS ignores what doesn't apply, but Play may ask you to justify broad storage permissions.
6. **Empty forced-update link** — `user_app_version_control.for_android.link` is `""`. App version (`1.0.0`) matches the gate, so nobody's walled out today, but set the real Play URL right after first publish or the next version bump strands users on a dead update prompt.
7. **Auction feature** — `active_auction_for_customer` is `false` in production, so it isn't a submission concern today. It's real-money bidding, though: read Play's Gambling & Contests policy *before* ever enabling it.

---

## Confirmed OK

- Package `com.meatsokogroup.user` consistent across Gradle, manifest, and `google-services.json` (Firebase `meatlab-29f15`).
- `compileSdk`/`targetSdk` = 36 — ahead of Play's minimum target requirement.
- `flutter analyze`: 65 issues, all lint-level, **zero compile errors**.
- No hardcoded secrets in `lib/` — the keys that exist are legitimately public client config.
- Production backend healthy; maintenance mode off for `user_app`; M-Pesa STK Push + Paystack configured (physical goods, so Play Billing doesn't apply).

## Before you hit submit

- Build an **App Bundle** (`flutter build appbundle --release`) — not tested yet with the new signing config; this is the next thing to verify.
- Store listing assets: feature graphic, screenshots, descriptions, category, contact email.
- **Data Safety form** — declare location, phone, email, name, and payment-adjacent data. Have an engineer check the draft against actual data flows.
- Content rating questionnaire.

## Suggested order

1. Real MeatSoko icon + adaptive icon — the last blocker.
2. Batch the quick wins as one PR: Facebook, cleartext, minify, Crashlytics (items 1-4).
3. `flutter build appbundle --release`, verify it signs, then fill in the listing and submit.
4. After enrolling in Play App Signing, add Google's cert fingerprint to `assetlinks.json`.
