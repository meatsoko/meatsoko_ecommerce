# User App — Final Feature Audit

**Living document.** Last updated: 2026-09-10 · Scope: `apps/user_app` (customer Android app) · 57 feature modules, 899 Dart files.

**Method:** static inspection of the current codebase (file:line cited), Android release configuration, and live probes of production (`shop.meatsokogroup.com`) — `/api/v1/config`, `/api/v1/banners`, `/.well-known/assetlinks.json`, and Google's Digital Asset Links API. `flutter analyze` run against current source.

## Status legend

| Badge | Meaning |
|---|---|
| ✅ **Verified** | Confirmed via code **and** config/live evidence |
| 🔵 **Implemented** | Code complete; needs device/manual runtime verification |
| 🟡 **Partial** | Some functionality incomplete or deliberately narrowed |
| ⚪ **Config-disabled** | Implemented, switched off in production today |
| 🔴 **Blocker** | Confirmed functional or release defect |
| ⚫ **Dead/legacy** | Present but not in the active product flow |

---

## Executive Summary

The app is **functionally complete and structurally sound** for a first release. `flutter analyze` reports **0 errors** (28 warnings, 37 infos — all lint-level). Production backend is healthy, not in maintenance mode, and correctly configured for Kenya (KES, multi-vendor, guest checkout on). App Links are live and verified by Google's own API. Signing, Maps, and policy pages are all done.

**One release blocker remains: the launcher icon is still 6valley template artwork.**

The largest *risk* is not code quality but **unverified runtime behaviour**. Payments are the clearest example: M-Pesa and Paystack have **no native Dart implementation at all** — checkout hands off to a server-hosted webview. That's a legitimate design, but it means the single most business-critical flow in the app is entirely unexercised by this audit and must be tested end-to-end on a device against a real transaction before launch.

There is also **no crash reporting** in the build. Combined with **zero automated test coverage**, the first production issue will surface as a user complaint rather than a dashboard alert.

**Verdict: NOT READY — 1 blocker remains.** After the icon ships and the manual QA checklist below passes, this becomes READY FOR RELEASE.

---

## Feature Matrix

| Feature | Status | Evidence | Production State | Manual Test Required |
|---|---|---|---|---|
| Email/password login | 🔵 Implemented | `features/auth/` | Enabled | Yes |
| Registration | 🔵 Implemented | `features/auth/` | Enabled | Yes |
| OTP verification | 🔵 Implemented | `features/auth/` | Config-driven | Yes |
| Password reset | 🔵 Implemented | `features/auth/` | Enabled | Yes |
| Google login | 🔵 Implemented | `only_social_login_widget.dart:70` | `social_login.google=true` | Yes |
| Facebook login | ⚪ Config-disabled | `only_social_login_widget.dart:69` hardcoded `0` | Server says `true`; client forces off | No |
| Apple login | 🔵 Implemented | `only_social_login_widget.dart:215` iOS-gated | `apple=true` | N/A (Android) |
| Guest access / checkout | 🔵 Implemented | `shipping_details_widget.dart:31` | `guest_checkout=1` | Yes |
| Logout | 🟡 Partial | Fix applied, never cleanly confirmed (`CLAUDE.md` §4) | — | **Yes** |
| Profile view/edit | 🔵 Implemented | `features/profile/` | — | Yes |
| Account deletion | 🔵 Implemented | `app_constants.dart:108`, `delete_account_bottom_sheet_widget.dart` | — | Yes (Play requirement) |
| Addresses | 🔵 Implemented | `features/address/` | — | Yes |
| Home | ✅ Verified | `home_explore_screen.dart` | Banners live (6 records) | Yes |
| Categories | 🔵 Implemented | `category_screen.dart` | 401 without auth — unverified | Yes |
| Product listing/details | 🔵 Implemented | `features/product_details/` | Unverified (auth-gated) | Yes |
| Product search | 🔵 Implemented | `features/search_product/` | — | Yes |
| Related products | ⚪ Config-disabled | `product_details_screen.dart:74-75` commented out | Off by code | No |
| Reviews/ratings | 🔵 Implemented | `features/review/` | — | Yes |
| Wishlist | 🔵 Implemented | `features/wishlist/` | — | Yes |
| Shop/vendor browsing | 🔵 Implemented | `features/shop/` | `business_mode=multi` | Yes |
| Cart | 🔵 Implemented | `features/cart/` | — | Yes |
| Coupons | 🔵 Implemented | `features/coupon/` | — | Yes |
| Delivery fees / free delivery | 🔵 Implemented | `features/shipping/` | `free_delivery_status=1`, `shipping_method=inhouse_shipping` | Yes |
| Checkout consent | ✅ Verified | `checkout_condition_checkbox.dart` | T&C/Privacy live | Yes |
| **M-Pesa (STK Push)** | 🔵 Implemented (webview) | No native Dart impl; `digital_payment_order_place_screen.dart:73` | `payment_methods` incl. `mpesa_stk` | **Yes — critical** |
| **Paystack** | 🔵 Implemented (webview) | Same webview path | Configured | **Yes — critical** |
| Cash on delivery | 🔵 Implemented | `features/checkout/` | `cash_on_delivery=true` | Yes |
| Wallet payment | 🔵 Implemented | `wallet_payment_widget.dart` | `wallet_status=1` | Yes |
| Offline payment | ⚪ Config-disabled | `offline_payment_widget.dart` | `offline_payment=null` | No |
| Order history/details | 🔵 Implemented | `features/order/`, `order_details/` | — | Yes |
| Order tracking | 🔵 Implemented | `features/tracking/` | — | Yes |
| Order cancellation | 🔵 Implemented | `app_constants.dart:102` | — | Yes |
| Refund/return | 🔵 Implemented | `refund_request_widget.dart` via order details | — | Yes |
| Reorder | 🔵 Implemented | `cancel_and_support_center_widget.dart` | — | Yes |
| Maps / location | 🔵 Implemented | `features/location/` | `map_api_status=1`; real key set | **Yes** |
| Banners | ✅ Verified | `banner_slider_widget.dart` | 6 published banners live | No |
| Push notifications | 🔵 Implemented | `main.dart:106-111`, `push_notification/` | Firebase `meatlab-29f15` | **Yes** |
| Referral | 🔵 Implemented | `features/refer_and_earn/` | `ref_earning_status=1` | Yes |
| Loyalty points | 🔵 Implemented | `features/loyaltyPoint/` | `loyalty_point_status=1` | Yes |
| Flash deals | 🔵 Implemented | `flash_deal_section.dart` | Endpoint returns empty | Yes |
| Announcements | ⚪ Config-disabled | — | `announcement.status=null` | No |
| **Auctions (10 modules)** | ⚪ Config-disabled | 18 gate checks across `lib/` | `active_auction_for_customer=false` | No |
| AI shopping assistant | ⚪ Config-disabled | `features/ai/` | `ai_shopping_assistant_status=0` | No |
| Deep links | ✅ Verified | `main.dart:182-189`; manifest `:85` | Google DAL API: `errorCode: none` | Yes |
| Localization | 🟡 Partial | 5 locales × 1406 keys each | No Swahili | No |
| Version/update gate | 🔵 Implemented | `features/update/screen/update_screen.dart` | `version=1.0.0`, `link=""` | Yes |
| Crash reporting | 🔴 Absent | No `firebase_crashlytics` in `pubspec.yaml` | — | — |

---

## Authentication

Full suite present: login, registration, OTP, reset, social. Google and Apple are server-gated; **Facebook is force-disabled client-side** at `only_social_login_widget.dart:65-71` because `strings.xml:3,5` still ship `YOUR_APP_ID` placeholders. Production `social_login` reports Facebook `true`, so the client override is the only thing preventing a broken button — fragile but currently safe.

`social_login_widget.dart:47-48` has the Facebook branch commented out as a second guard.

**Logout** carries history: `LogoutCustomBottomSheetWidget` was moved from `showModalBottomSheet` to `showGeneralDialog` after taps were being swallowed. Documented as "fix applied, not cleanly confirmed" (`CLAUDE.md` §4). ~17 other `showModalBottomSheet` call sites were never checked for the same root cause.

## Shopping

Home, categories, listing, details, search, reviews, wishlist, and multi-vendor shop browsing are all implemented. Catalog endpoints return `401 Unauthorized` without a bearer token, so **catalog content could not be verified anonymously** — product/category data must be confirmed on-device while logged in.

**Product details has deliberately disabled surface area** — `product_details_screen.dart:74-75` comments out the related-products fetch, and 11 imports at the top are commented out (Specifications, Reviews-and-Specification, YouTube video, "more from this shop", Promise widget). This is a design decision from the redesign commit, not an accidental break, but it is real functionality that silently disappeared.

## Cart & Checkout

Cart, coupons, address selection, guest checkout, and consent are wired. `system_tax_include_status=0` and `minimum_order_amount_status=0` in production. Shipping is `inhouse_shipping` with free delivery enabled.

## Orders

History, details, tracking, cancellation, refund, and reorder all exist. Refund and reorder have **no top-level routes** — they're reached from order-detail widgets (`refund_product_widget.dart`, `cancel_and_support_center_widget.dart`), so they're easy to miss in QA.

## Maps & Location

`map_api_status=1` server-side and a real Maps key is now in `AndroidManifest.xml:45`. Location, geocoding, and map widgets are implemented. **Never exercised at runtime in this audit** — map rendering, permission prompts, and address-picking need device testing.

## Payments

**The most important finding of this audit.** Grepping all of `lib/` for `mpesa` returns **zero matches**; `paystack` appears once, as an image asset path (`images.dart:100`).

Payment is generic: checkout opens `DigitalPaymentScreen`, which loads a **server-hosted payment page in a WebView** (`digital_payment_order_place_screen.dart:73`) and detects completion by URL sniffing for `success`/`fail`/`cancel` plus a token (`:76-78`).

Consequences:
- Gateway behaviour is entirely backend-owned; the app can't be assumed correct from its own source.
- The redirect detection is string-matching — brittle if the backend changes callback URLs.
- The payment webview runs under a global `cleartextTrafficPermitted="true"` (see Known Issues P1).

## Promotions / Referrals

Banners verified live (6 published records). Referral, loyalty, and wallet are all enabled server-side. Flash deals implemented but the endpoint currently returns empty — expected to be merchandising-dependent, not a defect.

## Auctions

Ten auction modules exist and are genuinely built (bidding, entry fees, wallet interaction, create-auction, transaction history), gated behind 18 checks on `isAuctionFeatureEnabled` / `showAuctionMenuForUser`.

**Production: `active_auction_for_customer=false`, `auction_feature_status=null` — fully off.** Out of scope for this release.

> ⚠️ Before ever enabling: this is real-money bidding with entry fees. Read Google Play's Gambling & Contests policy first — enabling it silently could put the listing at risk.

## Deep Links

✅ **Fully verified.** `AndroidManifest.xml:85` → `shop.meatsokogroup.com` in an `autoVerify="true"` filter covering `/product/`, `/vendor-shop/`, `/track-order`, `/referral-login`, `/auction/product/`. Runtime handling at `main.dart:182-189`.

Live `assetlinks.json` serves valid JSON as `application/json` with the correct package and production SHA-256; **Google's Digital Asset Links API resolves it with `errorCode: none`**.

> Only the upload certificate is listed. If you enrol in Play App Signing, Google re-signs and devices check *its* fingerprint — add that one too or links break for Play installs while still working when sideloaded.

## Account

Profile, editing, addresses, notifications, preferences present. **Account deletion is implemented** (`app_constants.dart:108`) — a Google Play requirement for account-based apps, so this is a compliance win worth confirming works.

## Notifications

Firebase correctly initialised with `DefaultFirebaseOptions.currentPlatform` (`main.dart:92`), background handler and initial-message handling registered (`:106-111`). Requires device testing — push cannot be verified statically.

## Localization

Five locales (en, ar, hi, bn, es), each with exactly **1406 keys** — no missing-key drift.

**No Swahili**, despite being a Kenya-first product (`country_code=KE`). Not a blocker; a market-fit gap.

## UI/UX

- **5 zero-byte Dart files**: `helper/api_checker_helper.dart`, `helper/text_helper.dart`, `theme/custom_theme_colors.dart`, `features/product/screens/view_all_product_screen.dart`, `features/wishlist/widgets/wishlist_search_widget.dart`.
- **Launcher icon is still 6valley template artwork** (verified visually) — see blocker.
- Blank error messages on certificate/connection failures (`api_error_handler.dart:98,101`) — a silent failure mode on flaky networks.
- 28 bare `print()` calls outside `kDebugMode` guards.

## Android / Play Store Readiness

| Item | State |
|---|---|
| `applicationId` / `namespace` | ✅ `com.meatsokogroup.user`, consistent with `google-services.json` |
| compile/target SDK | ✅ 36 / 36 |
| Release signing | ✅ `build.gradle.kts:56` → release config; `key.properties` present, gitignored |
| Maps API key | ✅ Real key set (`AndroidManifest.xml:45`) |
| App Links + assetlinks | ✅ Verified live via Google DAL API |
| Privacy policy / T&C | ✅ Live URLs + bundled in-app |
| Launcher icon | 🔴 **Template artwork; no adaptive icon** |
| Cleartext HTTP | 🟡 Globally permitted |
| Minify / shrink | 🟡 Not configured |
| Crashlytics | 🔴 Absent |
| Version | `1.0.0+1`; `AppConstants.appVersion='1.0.0'` — in sync |
| Play update URL | 🟡 `link=""` in `user_app_version_control` |
| Firebase | ✅ `meatlab-29f15` |
| Debug config in release | ✅ None found (`isDebuggable` not set) |

---

## Confirmed Working

Only items with code **and** live/config evidence:

1. **Deep links / App Links** — Google DAL API confirms, `errorCode: none`.
2. **Home banners** — 6 published records served live.
3. **Privacy policy & T&C** — live URLs (HTTP 200) plus bundled in-app copies.
4. **Release signing** — keystore valid (alias `upload`, to 2054), wired to release build.
5. **Package identity & Firebase config** — consistent across Gradle, manifest, `google-services.json`.
6. **Backend health** — config responds; maintenance off; Kenya/KES/multi-vendor correct.
7. **Localization key integrity** — 5 locales, 1406 keys each, no drift.
8. **Static code health** — `flutter analyze`: 0 errors.

## Requires Manual QA

Concrete cases, priority-ordered:

**Payments (critical — nothing here is statically verifiable)**
1. Complete a real M-Pesa STK Push order end-to-end; confirm the webview returns and the order is created.
2. Cancel an M-Pesa payment mid-flow; confirm the app recovers and doesn't create a phantom order.
3. Complete a Paystack order end-to-end.
4. Place a cash-on-delivery order.
5. Pay using wallet balance.
6. Force a payment failure; confirm the `fail`/`cancel` redirect detection (`:76-78`) fires correctly.

**Auth**
7. Register a new account; confirm session persists across app restart.
8. Google Sign-In on a real device.
9. **Logout via the account screen** — confirm both "Sign Out" and "Cancel" respond (known-flaky).
10. Password reset via OTP.
11. Guest browse → add to cart → guest checkout.
12. Account deletion (Play compliance).

**Shopping & orders**
13. Browse categories and confirm real catalog data loads (unverifiable anonymously — 401).
14. Search, open a product, add to cart with variations.
15. Apply a coupon; confirm totals.
16. Place order → view history → open details → track.
17. Cancel an order; request a refund from order details.

**Maps, notifications, deep links**
18. Grant location permission; confirm map renders with the new API key.
19. Pick a delivery address on the map; confirm geocoding.
20. Receive a push notification foreground **and** background; confirm tap-through.
21. Open `https://shop.meatsokogroup.com/product/<slug>` from an external app — must open the app, not a browser (requires a build signed with the audited cert).

## Known Issues

### P0 — Release blocker
1. **Launcher icon is 6valley template artwork.** No `mipmap-anydpi-v26/` (no adaptive icon). `user_app/pubspec.yaml` has **no** `icons_launcher`/`flutter_icons` config (only `vendor_app` does) and no source icon at `assets/images/ic_launcher.png` — needs artwork *and* config before a generator can run.

### P1 — Should fix before launch
2. **No crash reporting.** No `firebase_crashlytics`; Firebase Core already wired, so this is a small add.
3. **Cleartext HTTP globally permitted** (`network_security_config.xml:3`) — especially relevant since payments run in a WebView.
4. **Facebook placeholders** in `strings.xml:3,5`, masked by a hardcoded client override. Get credentials or remove the feature.
5. **Blank error messages** for `badCertificate`/`connectionError` (`api_error_handler.dart:98,101`) — users see nothing on network failure.
6. **Logout unconfirmed** (`CLAUDE.md` §4) plus ~17 unaudited `showModalBottomSheet` sites sharing the suspected root cause.
7. **No release minification/shrinking** — larger artifact, no obfuscation.

### P2 — Post-launch
8. Empty Play update `link` — set immediately after first publish or the next version bump strands users.
9. Only the upload cert in `assetlinks.json` — add Play App Signing's fingerprint on enrolment.
10. Permissions hygiene: no `maxSdkVersion` caps on storage perms; legacy `BLUETOOTH`/`BLUETOOTH_ADMIN` against `targetSdk=36`.
11. Zero automated test coverage (default counter-app smoke test only).
12. 28 unguarded `print()` calls.

### P3 — Polish
13. 5 zero-byte Dart files.
14. No Swahili localization for a Kenya-first product.
15. 14 substantive TODO/FIXME comments (excluding 157 template CRUD stubs).
16. Hardcoded auction filter caps (`auction_filter_param_model.dart:42-43`).

## Disabled / Deferred Features

**Intentional — do not "fix" these:**

| Feature | Where | Why |
|---|---|---|
| Facebook login | `only_social_login_widget.dart:69` | Placeholder App ID; forced off deliberately |
| Related products + 5 product-detail sections | `product_details_screen.dart:74-75` + 11 commented imports | Redesign decision |
| All auction features | 18 config gates | `active_auction_for_customer=false` |
| AI shopping assistant | `features/ai/` | `ai_shopping_assistant_status=0` |
| Offline payment | `offline_payment_widget.dart` | `offline_payment=null` |
| Announcements | — | `announcement.status=null` |
| Address quick-action card | `more_screen_view_new.dart` (commented) | Deferred with a re-enable note |

## Dead / Legacy Code

- **~157 template CRUD stubs** across repositories implementing a generic interface with `throw UnimplementedError()` (`add`/`delete`/`getList`/`update`/`get`). Never called — real repos override with different signatures. **Landmine:** any future call through the generic interface crashes immediately.
- **5 zero-byte files** (listed under UI/UX).
- `features/product/screens/view_all_product_screen.dart` is empty; the working screen is `features/home/screens/view_all_product_screen.dart` (`route_healper.dart:50`).

## Production Configuration

Verified live against `/api/v1/config` (non-secret only):

| Key | Value |
|---|---|
| `country_code` | `KE` |
| currency | KES (`system_default_currency=8`) |
| `business_mode` | `multi` |
| `guest_checkout` | `1` |
| `payment_methods` | `mpesa_stk`, `paystack` |
| `cash_on_delivery` | `true` |
| `digital_payment` | `true` |
| `wallet_status` / `loyalty_point_status` / `ref_earning_status` | `1` / `1` / `1` |
| `shipping_method` | `inhouse_shipping` |
| `free_delivery_status` | `1` |
| `map_api_status` | `1` |
| `active_auction_for_customer` | `false` |
| `ai_shopping_assistant_status` | `0` |
| `maintenance_mode.user_app` | `0` (off) |
| `user_app_version_control` | `1.0.0`, `link=""` |

---

## Final Recommendation

# ❌ NOT READY — BLOCKERS REMAIN

**Blocker:**
1. **P0 — Launcher icon is still 6valley template artwork**, with no adaptive icon and no generator config in `user_app/pubspec.yaml`.

Once that ships, the gate becomes **READY AFTER MANUAL QA** — specifically the 21 test cases above, with **payments (cases 1-6) non-negotiable**, since M-Pesa and Paystack have no native code and cannot be validated by inspection.

**Strongly recommended in the same release:** Crashlytics (P1 #2) — without it, launch-day issues are invisible until users complain.
