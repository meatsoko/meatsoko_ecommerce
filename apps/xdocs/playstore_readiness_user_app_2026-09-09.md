# Play Store Production Readiness — User App

**Date:** 2026-09-09
**Scope:** `user_app/` only, Android/Play Store submission specifically (iOS/App Store is out of scope for this report — see `gap_audit_2026-09-07.md` §D.1 for its separate, unrelated build failure).
**Method:** Direct inspection of `AndroidManifest.xml`, `build.gradle.kts`, `strings.xml`, `network_security_config.xml`, app icon assets (visually confirmed), `pubspec.yaml`, relevant Dart source; a live probe of the production `/api/v1/config` endpoint; `flutter analyze` run fresh against current source; cross-checked against `gap_audit_2026-09-07.md`, `mobile_customization_log.md`, and `CLAUDE.md`, with functional-bug items carried over only where independently plausible and cited back to their original source rather than re-verified line-by-line here.

## Verdict: **Not ready.** 5 hard blockers, all fixable without touching the backend or app architecture.

None of the blockers below are deep engineering problems — they're unfinished setup steps (a keystore was never generated, two manifest placeholders were never replaced, the backend privacy-policy field was never filled in, and the icon was never swapped). Realistic turnaround once someone sits down to do it: **under a day** for the code/config side; the privacy policy also needs an actual policy document to exist and be hosted somewhere, which may be the longer pole.

---

## 1. Hard blockers — will cause rejection or ship a broken app

### 1.1 Release build is signed with the debug keystore
`android/app/build.gradle.kts:53-55`:
```kotlin
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("debug") // or "release" if you have real keystore
    }
}
```
A `signingConfigs.create("release")` block exists (lines 44-49) and correctly reads from `key.properties`, but nothing ever points the `release` build type at it — and no `key.properties` or `.jks`/`.keystore` file exists anywhere in the repo (confirmed: `find android -iname "*.jks" -o -iname "*.keystore"` → no results; `key.properties` is correctly gitignored but was never created). Every release build produced today is signed with Flutter's shared, publicly-known debug key.

**Fix:** generate a real upload keystore (`keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`), create `android/key.properties` pointing at it, and change line 54 to `signingConfigs.getByName("release")`. **Store the keystore and its passwords somewhere durable and backed up outside the repo** — losing it means you can never publish an update to this app listing again.

### 1.2 Google Maps API key is a literal placeholder
`android/app/src/main/AndroidManifest.xml:36`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_MAP_KEY_HERE" />
```
Every feature using `google_maps_flutter`/`geocoding`/`geolocator` for on-map display (delivery address picking, shop location, order tracking map) will fail to render at runtime.

**Fix:** create a real Maps SDK for Android key in Google Cloud Console (same GCP project as Firebase, `meatlab-29f15`, is fine) restricted to this app's package name + SHA-1, and replace the placeholder.

### 1.3 App Links host is a literal placeholder
`android/app/src/main/AndroidManifest.xml:87`:
```xml
<data android:host="YOUR_DOMAIN_HERE"/>
```
This sits inside an `autoVerify="true"` intent-filter meant to make `https://<real-domain>/product/…`, `/vendor-shop/…`, `/track-order`, `/referral-login`, `/auction/product/…` links open directly in the app. With a placeholder host, Android's Digital Asset Links verification cannot succeed and none of these links will ever open the app — they'll just open a browser. This is a silent failure, not a crash, so it's easy to ship without noticing.

**Fix:** set `android:host="shop.meatsokogroup.com"` (or whatever the real customer-facing domain is), and publish the matching `assetlinks.json` at `https://<host>/.well-known/assetlinks.json` referencing this app's package name and release-signing certificate's SHA-256 fingerprint (which only exists once §1.1 is fixed — do that first).

### 1.4 No privacy policy configured — confirmed empty in production, right now
Play Console requires a working privacy policy URL in the store listing for every app, and this app collects location, phone number, and account data, which makes it non-negotiable. I checked this isn't just an app-side gap — it's actually unset on the live backend:
```
$ curl -s https://shop.meatsokogroup.com/api/v1/config | jq '.privacy_policy, .about_us'
None
None
```
The app already has the plumbing for this (`ConfigModel.privacyPolicy` reads `config['privacy_policy']`, and it's surfaced via `more_screen_view_new.dart` and the checkout consent checkbox) — there's just nothing there to show.

**Fix:** this is primarily an operational task, not a code task — write/host a real privacy policy and set it in Admin → System Setup, then paste the same URL into the Play Console store listing's Privacy Policy field. Given the location/PII collection here, worth having this reviewed rather than boilerplate-generated.

### 1.5 App icon is the unmodified template default, no adaptive icon
Confirmed by direct visual inspection of `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` — it's the generic blue-hexagon-with-shopping-cart icon from the 6valley template, not MeatSoko branding (already tracked as not-started in `CLAUDE.md` §4, confirmed still true here). Additionally, `mipmap-anydpi-v26/` (the modern adaptive-icon format) doesn't exist at all — only legacy flat PNGs are present, which is allowed but looks dated/unpolished on any launcher from Android 8+ onward, and Play Console's pre-launch report will flag it.

**Fix:** the project already has `icons_launcher`/`flutter_icons` config wired in `pubspec.yaml` pointing at `assets/images/ic_launcher.png` — someone just needs to drop a real MeatSoko icon at that path and run the icon generator (`dart run icons_launcher:create` or equivalent), which will also produce the adaptive-icon variant.

---

## 2. Should-fix before submission — policy risk or real quality issues, not automatic rejections

### 2.1 Facebook login: real credentials or a real removal, not a hardcoded override
`android/app/src/main/res/values/strings.xml:3-5` still ship literal placeholders (`facebook_app_id` = `YOUR_APP_ID`, `facebook_client_token` = the instructional text `Go_to_your_fb_app->Settings->Advance->Security->Client token`). Production's own config currently reports `social_login: facebook.status = True` (server thinks it's on), but the app protects itself with an explicit client-side override — `only_social_login_widget.dart:65-71`:
```dart
final socialLogin = SocialMediaLoginOptions(
  // Facebook login disabled: strings.xml/Info.plist still ship the placeholder
  // App ID (YOUR_APP_ID). Was previously hardcoded to 1 regardless of server
  // config — forced to 0 until real credentials are configured.
  facebook: 0,
  google: 1,
  apple: 1
);
```
So today's actual runtime behavior is safe (no visible Facebook button, no crash) — but it's a fragile, easy-to-forget override sitting on top of broken config, not a real fix. Google Sign-In is properly configured (`google-services.json` present and correct) and unaffected.

**Fix (either path is fine for Play submission):** get real Facebook app credentials and remove the override, or decide Facebook login isn't launching with v1 and delete the dead UI/dependency (`flutter_facebook_auth`) entirely instead of leaving a permanently-disabled button path in the codebase.

### 2.2 Cleartext HTTP traffic permitted globally
`android/app/src/main/res/xml/network_security_config.xml`:
```xml
<base-config cleartextTrafficPermitted="true">
```
This applies to *all* domains, not just a scoped dev/local exception, and pairs with `android:usesCleartextTraffic="true"` in the manifest. The app's own `baseUrl` is already `https://` (`AppConstants.baseUrl`), so this is broader than anything the app actually needs — it's attack surface (MITM on any accidental or third-party-SDK plaintext request) with no corresponding benefit in production.

**Fix:** set `cleartextTrafficPermitted="false"` at the base level, and add a narrowly-scoped `<domain-config>` override only if a specific local/dev host genuinely needs HTTP.

### 2.3 No release-build shrinking/obfuscation configured
No `minifyEnabled`, `shrinkResources`, or ProGuard/R8 rules are set anywhere in `android/app/build.gradle.kts`'s `release` block. Not a rejection cause, but it means a larger APK/AAB than necessary and no baseline obfuscation of app code.

**Fix:** add `isMinifyEnabled = true`, `isShrinkResources = true`, and a `proguard-rules.pro` (Flutter's default template rules are a safe starting point; will need testing since some plugins — reflection-heavy ones especially — need explicit keep rules).

### 2.4 No crash/error visibility in production
`pubspec.yaml` has no `firebase_crashlytics` or equivalent (confirmed by grep — no matches). Firebase Core is already wired for this project (`meatlab-29f15`), so adding Crashlytics is a small, low-risk addition, not a new integration from scratch. Without it, the team's only way to learn about a production crash is a user complaint.

**Fix:** add `firebase_crashlytics`, initialize it alongside the existing `Firebase.initializeApp` call, wire `FlutterError.onError`/`PlatformDispatcher.instance.onError` to report to it. Worth doing before launch, not urgent enough to block a first submission if time is tight.

### 2.5 Auction (real-money bidding) feature — confirm policy posture before ever enabling
The auction feature (`active_auction_for_customer` in server config) is **currently `False` in production** — confirmed live, so it isn't a submission blocker today. But it's real, wired functionality (per `CLAUDE.md` §3: "livestock/product bidding with entry fees and wallet payment... not a demo stub"), and Play Store's gambling/gambling-adjacent content policy applies scrutiny to real-money bidding mechanics regardless of the underlying goods being physical livestock. Worth a deliberate policy read (Play's Gambling and Contests policy) *before* anyone flips that flag on in production, rather than discovering a policy strike after the fact. Not a fix to make now — a decision to make consciously later.

### 2.6 Over-broad/legacy permissions for the declared `targetSdk`
`AndroidManifest.xml:9-14` declares `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `BLUETOOTH`, `BLUETOOTH_ADMIN` without `android:maxSdkVersion` caps, alongside `targetSdk = 36` (`build.gradle.kts:32`) and `android:requestLegacyExternalStorage="true"` (manifest line 35, which the OS silently ignores past API 29 — dead config, not harmful, just stale). On API 30+, `WRITE_EXTERNAL_STORAGE` grants nothing; on API 31+, Bluetooth should be requested via the newer `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` permissions instead. None of this blocks submission — the OS just ignores the parts that don't apply — but it's manifest hygiene worth cleaning up, and Play Console's permissions declaration UI may ask for justification of the broad storage permissions if it still detects them as meaningfully requested.

**Fix:** add `android:maxSdkVersion="29"` to both storage permissions (scoped storage covers everything past that via `READ_MEDIA_*`, one of which — `READ_MEDIA_AUDIO` — is already correctly present), and migrate to `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` for the printing/barcode-scanning features that need Bluetooth on modern Android.

### 2.7 Forced-update link is empty
Production config: `user_app_version_control.for_android = {status: 1, version: '1.0.0', link: ''}`. The app's own version (`AppConstants.appVersion = '1.0.0'`, `pubspec.yaml: version: 1.0.0+1`) currently matches, so this isn't walling anyone out today — but per the standing risk already documented in `CLAUDE.md` §7, the moment this version number is bumped without also setting a real Play Store link here, any forced-update prompt sends users nowhere useful.

**Fix:** set `link` to the real Play Store listing URL once one exists, as part of the actual submission process (chicken-and-egg with first publish — just don't forget it on the *first* update after launch).

### 2.8 Known functional bugs worth closing before a first release, not after
Carried over from `gap_audit_2026-09-07.md` (see that doc for full detail/line numbers) — flagged here specifically because they affect an app about to face real end users for the first time, not because this report re-verified each one independently:
- Blank error message on certificate/connection failures (`user_app/lib/data/datasource/remote/exception/api_error_handler.dart:97-100`) — a user on a flaky connection sees nothing.
- Product-details page has several sections quietly disabled since the recent redesign (Specifications, Related Products, Reviews-and-Specification, video widget, "more from this shop", Promise widget) — worth an explicit decision (bring back vs. formally cut) rather than shipping as an accidental gap.
- The Sign-Out bottom-sheet fix (`LogoutCustomBottomSheetWidget`) is "fix-applied-and-probably-working" per `CLAUDE.md`, not cleanly confirmed — worth a final manual pass before launch given it's a core account-management flow.

---

## 3. Nice-to-have / polish — non-blocking

- **No Swahili localization** despite being a Kenyan storefront (5 shipped locales are ar/bn/en/es/hi — none is the obviously-relevant one for this market).
- **Zero real automated test coverage** — both apps only carry the default `flutter create` counter-app smoke test (`CLAUDE.md` §8, confirmed still true in `gap_audit` §D.2). Not a submission blocker, but means every finding in this report and the gap audit was caught by manual reading, not CI.
- **~35 template repository classes** across the app implement a generic interface whose methods just `throw UnimplementedError()` — dead code today (the real repos override with different signatures), but a landmine for any future contributor who calls the generic interface method.
- Scattered `print()` calls left in non-debug-gated code paths (e.g. `shop_screen.dart:85-86,141-142`, flagged by `flutter analyze`) — harmless but unpolished; a release build shouldn't be writing to logcat by default.

---

## 4. Confirmed OK — checked directly, no action needed

- **Package identity:** `applicationId`/`namespace` = `com.meatsokogroup.user`, matches `google-services.json`'s registered package for Firebase project `meatlab-29f15`. Consistent, no rename residue.
- **`flutter analyze`** on current `lib/` source: 65 issues, all lint-level (unused params, `print` usage, leading-underscore naming) — **zero compile errors.**
- **No hardcoded secrets found** in `lib/utill/app_constants.dart` or elsewhere searched — API keys that exist are either correctly placeholder'd (Maps, Facebook — both flagged above as needing real values) or legitimately public client config (`google-services.json`).
- **`targetSdk`/`compileSdk` = 36** — ahead of, not behind, current Play Store minimum target API requirements; not a submission risk.
- **Production backend health:** `/api/v1/config` responds correctly; `maintenance_mode.selected_maintenance_system.user_app = 0` (not blocking users); `guest_checkout` enabled; payment gateways configured (M-Pesa STK Push, Paystack) — both fine to use without Google Play Billing since this is a physical-goods marketplace, not digital goods/virtual currency.
- **Apple Sign-In** is correctly gated to iOS only (`defaultTargetPlatform == TargetPlatform.iOS` in `only_social_login_widget.dart:215`) — irrelevant to this Android-only report, not a gap.
- **Privacy-policy/consent plumbing** exists and is server-driven (`ConfigModel.privacyPolicy`, checkout consent checkbox) — the *mechanism* is fine, only the *content* (§1.4) is missing.

---

## 5. Store-listing checklist (outside the codebase, for completeness)

Not independently verifiable from source — flagging as required Play Console steps once the code-side blockers above are closed:
- App Bundle (`.aab`), not a bare `.apk`, for the Play Console upload — confirm the release build pipeline produces one (`flutter build appbundle`).
- Feature graphic, screenshots (phone + any tablet claim), short/full description, app category, contact email — standard listing assets, none of this exists in the repo to check.
- **Data Safety form** — must accurately declare what's collected (location, phone number, email, name, payment-adjacent data via the gateways) and why; this is a compliance document, not code, but gets it wrong easily if whoever fills it out doesn't know what the app actually collects. Worth having an engineer review the draft against this app's real data flows before submission.
- **Content rating questionnaire** — flag the auction/bidding feature explicitly if it's ever turned on, even though it's off today (§2.5).

---

## Suggested fix order

1. Generate the release keystore and wire it up (§1.1) — unblocks everything else that depends on having a real signing certificate.
2. Real Maps API key, real App Links host + hosted `assetlinks.json` (§1.2, §1.3) — quick, independent of each other.
3. Get a privacy policy written/hosted and set on the backend (§1.4) — likely the longest lead time item, start it in parallel with the above.
4. Real MeatSoko app icon + adaptive icon generation (§1.5).
5. Resolve Facebook (credentials or removal), tighten `network_security_config`, add release minification, add Crashlytics (§2.1-2.4) — batchable as one PR.
6. Manual pass on the known functional bugs (§2.8), particularly the Sign-Out confirmation and the blank error-message cases.
7. Build the release AAB, fill out the Play Console listing + Data Safety form, submit.
