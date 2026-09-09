# Mobile Apps in This Repo — What's Included

**Scope:** the two Flutter app trees at repo root — `User app/` (customer app) and `Vendor app/` (seller app). This is a status/inventory report, not a changes report — it answers "what exists here and what state is it in," independent of any git branch.

**Bottom line:** these are the stock **6valley** (by 6amTech) Flutter apps from the licensed commerce package — version 16.2.1 — wired to talk to the same backend as the web storefront (`Admin and web new install V16.2.1/`). They have **not** been rebranded to MeatSoko: app names, bundle IDs, and every user-facing string still say "6Valley." They also aren't pointed at the MeatSoko backend yet — the API base URL is a placeholder. A recent commit made both apps compile cleanly again after the vendor's 16.2 → 16.2.1 upgrade broke the build; no other app-specific feature work has happened in this repo.

---

## 1. Identity — still the unbranded template

| | User app | Vendor app |
|---|---|---|
| App name (Android/iOS label) | `6Valley` | `6Valley Vendor` / `6valley Seller` |
| Android package (`applicationId`) | `com.sixamtech.sixvalley` | `com.sixamtech.sixvalley.seller` |
| iOS bundle ID | `com.sixamtech.sixValley` | `com.sixamtech.sixvalley.seller-seller` |
| Flutter package name | `flutter_sixvalley_ecommerce` | `sixvalley_vendor_app` |
| pubspec version | `1.0.0+0` | `1.0.3+5` |

A repo-wide search for "MeatSoko" across both apps' `lib/` and `assets/` returns **zero matches**. "sixvalley"/"6valley" appears 737 times in the User app's `lib/` alone. None of the rebranding work done on the web storefront (this session's navbar/footer/login reskin, or the earlier MeatSoko home-page redesign) has touched these apps — they're a separate, untouched codebase.

**Firebase config is also mismatched**, not just unbranded: `google-services.json` in both apps points at a project (`drivevalley-fdb7f`) whose registered Android package names are `com.sixamtech.delivery`, `com.sixamtech.hexariderider`, `com.sixamtech.hexarideuser`, `com.sixamtech.hexaride` — none of which match either app's actual `applicationId`. This looks like a leftover config file from a different 6amTech demo product (a ride-hailing template, judging by the package names), not this e-commerce app. Push notifications and Firebase-based social login will likely fail silently until a real `google-services.json`/`GoogleService-Info.plist` scoped to the correct package names is generated in Firebase console and swapped in.

## 2. Backend wiring — not yet connected

`lib/utill/app_constants.dart` in both apps:
```dart
static const String baseUrl = 'YOUR_BASE_URL_HERE';
```
Neither app is pointed at `shop.meatsokogroup.com` or any other live backend — this is the vendor's unfilled placeholder. Everything below describes what the apps *can* do once that's set and the app is rebuilt; none of it has been exercised against the real MeatSoko backend from within this repo.

The API surface itself (`/api/v1/...` routes for categories, brands, products, auth, etc.) matches the same Laravel backend in `Admin and web new install V16.2.1/routes/rest_api/`, so no backend changes are needed to connect them — this is a configuration step, not a development one.

## 3. User app (customer) — feature inventory

57 feature modules under `lib/features/`. Grouped by area:

- **Shopping core:** home, category, brand, product, product_details, search_product, cart, checkout, coupon, deal, clearance_sale, compare, wishlist, review.
- **Orders & fulfillment:** order, order_details, tracking, reorder, refund, restock, shipping, vat_tax, offline_payment.
- **Account & auth:** auth (manual/OTP/social login — matches the web's login options), profile, address, dashboard, setting, wallet, transaction, loyaltyPoint, refer_and_earn, notification.
- **Support & content:** chat, support, contact_us, blog, banner, more, onboarding, splash, maintenance, update, location.
- **AI:** an `ai` module (product-related AI assistance, mirroring the backend's `Modules/AI`).
- **Auction (livestock/product bidding):** the largest single group — `auction`, `auction_category`, `auction_checkout`, `auction_dashboard_summary`, `auction_details`, `auction_home`, `auction_list`, `auction_search`, `auction_transaction`, `create_auction`, `user_created_auction_list`. This mirrors the backend's `Modules/Auction` feature and is gated behind the same server-driven `isAuctionFeatureEnabled` config flag the web app reads — it's a real, currently-wired feature, not a demo leftover, though see §5 on how recently it was made to compile.

**Payment methods referenced in code** (as icons/branches, not hardcoded gateway SDKs — actual availability is server-config-driven, same as the web app): PayPal, Stripe, Razorpay, Paystack, Flutterwave, offline/manual payment, wallet, cash on delivery. **No M-Pesa-specific asset or code path exists in either app** — the web backend's M-Pesa STK/C2B integration (hardened in a recent commit) has no mobile-native counterpart here; if M-Pesa needs to work from the apps, it would have to go through the generic "offline payment" flow or a webview, and that hasn't been verified.

**Localization:** 5 languages bundled — English, Arabic, Bengali, Spanish, Hindi. No Swahili, despite this being a Kenyan storefront — worth flagging if local-language support matters for launch.

## 4. Vendor app (seller) — feature inventory

36 feature modules under `lib/features/`:

- **Catalog & inventory:** addProduct, product, product_details, clearance_sale, restock, coupon, vat_management, barcode.
- **Orders & POS:** order, order_details, order_edit, pos (point-of-sale, for in-person/counter sales), delivery_man, shipping, refund.
- **Shop & finance:** shop, dashboard, wallet, transaction, bank_info.
- **Account:** auth, profile (via `settings`), language, menu, more, notification, emergency_contract.
- **Auction:** a single `auction` module (seller-side: creating/managing auction listings), smaller than the User app's auction surface since most auction browsing/bidding logic lives customer-side.
- **AI:** matching `ai` module.

## 5. Build health — currently compiles clean

The only app-specific development that's happened in this repo is one commit (`4c03a99`, "fix: resolve Flutter build errors in User/Vendor apps") that repaired a broken build left over from the vendor's 16.2 → 16.2.1 upgrade:

- **User app:** ~30 missing auction-module files (controllers, repositories, services, models, enums) were stubbed in, resolving ~330 compile errors. Also fixed 7 runtime crash bugs: unhandled non-JSON API error bodies, an unhandled request-timeout case, empty geocoding results crashing location lookup, unguarded `double.parse` calls in the wallet and loyalty-point dialogs, unguarded list indexing in two order-details widgets, and a missing `context.mounted` check in the auction bid widget.
- **Vendor app:** two missing repository interfaces, two missing notification-repository methods, and one missing price-converter method were added; a `PaymentMethodBottomSheetWidget` was built for the auction admin-commission payment flow.

I re-ran `flutter analyze` on both apps just now to confirm current state:

| | User app | Vendor app |
|---|---|---|
| Real errors in `lib/` | **0** | **0** |
| Lint warnings/info | 475 | 516 |

Both apps compile without errors. The "error" lines `flutter analyze` reports are all inside `build/ios/SourcePackages/.../firebase_auth-6.5.7/example/` — cached example code from a third-party CocoaPods package, not this app's source, and not part of the git repo (`build/` is gitignored). The 475/516 figures are ordinary lint noise (unused imports/variables, `print()` calls, missing `const`, deprecated API usage) — normal for a template project, not blockers.

**Test coverage:** each app has exactly one test file (`test/widget_test.dart`), and it's the default Flutter counter-app smoke test scaffolded by `flutter create` — it doesn't test anything this app actually does. There is no real automated test coverage for either mobile app.

## 6. Platform targets

| | User app | Vendor app |
|---|---|---|
| Android compileSdk | 36 | Flutter default (`flutter.compileSdkVersion`) |
| Android targetSdk | 36 | Flutter default |
| iOS deployment target | 13.0–15.6 (varies by target) | 13.0–14.0 (varies by target) |
| Flutter SDK (per README) | 3.41.4 | 3.44.2 |

Both apps declare standard permissions for an e-commerce app: internet/network state, storage read/write, coarse+fine location (User app only — for delivery address/geocoding), Bluetooth (barcode/POS hardware), and media audio.

## 7. What's *not* in this repo

- **No delivery-man app.** Both READMEs note `Deliveryman : 5.1` as a compatible version, implying a third companion app exists in the broader 6valley product line, but it isn't part of this repository.
- **`Apps changed files from V16.2 to V16.2.1/`** is not custom work — it's the vendor's officially published file-diff package for customers upgrading an existing 16.2 install without re-downloading the full app source (per `Readme.txt`). It duplicates a subset of files already present in full inside `User app/` and `Vendor app/`.

---

## Summary

The mobile apps are a complete, compiling, feature-rich e-commerce app pair (customer + vendor) with a real auction/livestock-bidding feature that aligns with MeatSoko's business — but they are **pre-launch infrastructure, not launch-ready product**. Before they could ship as MeatSoko-branded apps, the remaining work is:

1. Rebrand: app name, bundle/package IDs, icons, splash, and any hardcoded "6valley"/"sixvalley" user-facing strings.
2. Point `baseUrl` at the real backend and verify the API contract end-to-end.
3. Replace the mismatched `google-services.json`/`GoogleService-Info.plist` with real Firebase config scoped to the correct package names.
4. Decide how M-Pesa payment will work from mobile (no dedicated integration exists today).
5. Consider adding Swahili to the bundled languages.
6. Add real test coverage — currently none exists beyond the unmodified Flutter scaffold test.

None of this is unusual for a licensed commerce template at this stage — it's the expected state before a branding/configuration pass, not a sign of broken or incomplete engineering.
