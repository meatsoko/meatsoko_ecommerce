# User App — Full Feature Blueprint

**What this is:** a complete inventory of every feature currently built into the customer-facing mobile app (`User app/`, Flutter package `flutter_sixvalley_ecommerce`), grounded in the actual source code (`lib/features/*`, `lib/common/`, `lib/helper/route_healper.dart`, and supporting infrastructure) — not guessed from directory names. It exists so a rebuild (on any stack) can reproduce every current capability without silently dropping something.

**What this is not:** a recommendation of what MeatSoko *should* keep, cut, or prioritize. This is a completeness baseline describing current template behavior only — a stock, unbranded 6valley app (see `xdocs/mobile_apps.md` for that context). Product decisions about scope come later, informed by this document, not decided by it.

---

## Table of contents

1. [Onboarding, Auth & Identity](#1-onboarding-auth--identity) — splash, onboarding, auth, auth widgets
2. [Home, Navigation & Discovery](#2-home-navigation--discovery) — dashboard, home (3 themes), category, brand, shop, search, banner, deal, clearance_sale
3. [Product & Catalog](#3-product--catalog) — product, product_details, review, compare, wishlist, restock
4. [Cart & Checkout](#4-cart--checkout) — cart, checkout, coupon, shipping, vat_tax, offline_payment
5. [Orders & Post-Purchase](#5-orders--post-purchase) — order, order_details, tracking, refund, reorder
6. [Auction / Livestock Bidding](#6-auction--livestock-bidding) — auction, auction_home, auction_category, auction_details, auction_checkout, create_auction, ai, auction_list, auction_search, auction_transaction, auction_dashboard_summary, user_created_auction_list
7. [Account, Wallet & Loyalty](#7-account-wallet--loyalty) — profile, address, location, wallet, loyaltyPoint, refer_and_earn, transaction
8. [Support & Content](#8-support--content) — chat, support, contact_us, blog, more, setting
9. [Notifications](#9-notifications) — notification, push_notification infra
10. [Platform / Infrastructure](#10-platform--infrastructure) — localization, theme, local cache (drift), maintenance, update, common widgets

---

## 1. Onboarding, Auth & Identity

### splash
**Purpose:** App entry point. Loads cached config instantly (if present), then refreshes from the API; decides where to route the user next.
**Screens/Flows:**
- Full-bleed brand splash (logo + app name + slogan on primary-color background) while config loads.
- Reads any pending push-notification payload (`FirebaseMessaging.instance.getInitialMessage()`) so a cold-start-from-notification still deep-links correctly after config loads.
- Routing decision tree after config resolves: forced-update screen (if app version below server minimum) → maintenance screen (if maintenance mode + notification didn't bypass it) → deep-link target (order/notification/wallet/chat/restock/auction) if opened from a notification → dashboard (logged in) → onboarding (first run) → dashboard as guest.
**Key capabilities/business rules:**
- Local-first: an API-response cache (see §10, local cache) is read before any network call, so a return visit can route instantly while a background refresh updates config.
- Distinguishes 6 notification-open types with distinct destinations: `order`, `notification`, `wallet`, `chatting` (further split by `messageKey == 'message_from_delivery_man'` vs. general chat), `product_restock_update`, and separate customer-side vs. seller-side auction notification type sets.
- No internet → dedicated `NoInternetOrDataScreenWidget` wrapping the splash itself (retry-in-place, not a separate screen).
**Dependencies:** backend `/api/v1/config` endpoint; Firebase Cloud Messaging for the initial-message check.

### onboarding
**Purpose:** First-run introduction slides.
**Screens/Flows:** Swipeable intro carousel with page indicator, "Skip" and "Explore" (finish) actions.
**Key capabilities/business rules:** Only shown once per install (config-driven "show intro" flag); after either exit path, routes to dashboard.
**Dependencies:** none beyond local state.

### auth (cluster: login, registration, OTP, password reset, social login)
**Purpose:** All identity entry points — manual login, registration, OTP-based login/registration, password recovery, and social sign-in — all config-gated so any combination can be turned on/off from the backend.
**Screens/Flows:**
- **Login screen** — unified email-or-phone field (auto-detects which, switches country-code picker in/out live as the user types), password field, remember-me (persists last-used credential locally), forgot-password link, config-gated "Sign in with OTP" link, config-gated social buttons, "Create an account" link, "Continue as Guest" link. If both manual and OTP login are disabled in config, renders a social-only variant instead (`OnlySocialLoginWidget`).
- **Sign-up screen** (`AuthScreen` → `SignUpWidget`) — first name, last name, email, phone (with country picker), password, confirm password, optional referral-code field (shown only when referral-earning is enabled in config), terms-acceptance checkbox (submit button disabled until checked). After successful registration, branches three ways based on config: send email OTP, send phone OTP, or log straight in.
- **OTP login screen** — phone-only entry, "Get OTP" → navigates to shared verification screen.
- **OTP registration screen** — a fast-path signup shown after a first-time social login when the account needs a name/email/phone before it's usable.
- **OTP verification screen** (shared by email verification, phone verification, and digital-product post-purchase verification) — boxed PIN code input, live countdown timer, resend action once the timer lapses.
- **Mobile verification screen** — used to attach/confirm a phone number to an account; explicitly checks for and rejects an already-registered phone number.
- **Forget password screen** — phone-number-based reset request.
- **Reset password screen** — new password + confirm, with mismatch validation.
- **Existing-account bottom sheet** — shown when a registration attempt collides with an existing account, offering a route straight to login.
**Key capabilities/business rules:**
- Client-side password rule: minimum 6 characters enforced before the login call is even made (server has its own rule too).
- "Remember me" persists the resolved login identifier (email or phone) and password locally for prefill on next open — not just a token.
- Guest mode issues a server-side `guest_id` used for browsing and a guest cart, which is merged into the real cart automatically the moment the user logs in (see Cart).
- Social login providers wired: **Google**, **Facebook**, **Apple** (Apple via `sign_in_with_apple`, effectively iOS-relevant). Each captures id/email/name/token and round-trips through the same backend social-login endpoint.
- RTL: language switching to Arabic flips the whole app to right-to-left automatically.
**Dependencies:** Firebase for OTP/social plumbing where applicable; Google/Facebook/Apple developer app credentials (all currently placeholder — see `xdocs/mobile_apps.md`); backend social-login endpoints; a configured captcha/recaptcha is *not* present in this app (unlike the web storefront) — no captcha step here.

---

## 2. Home, Navigation & Discovery

### dashboard
**Purpose:** The app's root shell — bottom navigation, and (distinctively) a full second app mode for auction browsing that the user can swap into from the same shell.
**Screens/Flows:**
- **Main mode tabs:** eCom (home) · Category · [center swap button → enters Auction mode] · Cart · Orders.
- **Auction mode tabs:** My Activity · My Bids · [center swap button → returns to Cart/main mode] · Category (auction categories) · Auction (auction home).
- A periodic (2-minute cooldown) promotional banner nudges users toward the auction feature from main mode.
- On login, immediately kicks off: guest-cart merge, wishlist load, two chat-list loads (customer + delivery-man threads), restock-request list, wallet transaction list, author/publishing-house lists (for digital-product filters).
- Loads "default" and "pages" business-page lists (About/Terms/etc.) up front so the More screen and footers don't have to wait.
**Key capabilities/business rules:**
- Auction mode is entirely config-gated (`isAuctionFeatureEnabled`); when off, the center swap button and auction tabs don't exist — the app behaves as a plain single-mode shopping app.
- `singleVendor` flag (from `business_mode` config) changes downstream behavior across several features (e.g., shop-related screens are skipped/altered in single-vendor mode).
- Selects one of **three complete alternate home page layouts** at startup based on config (`activeTheme`): `default`, `theme_aster`, or a "fashion" theme — see the `home` module below. All three are fully built, not stubs.
**Dependencies:** none beyond the feature controllers it wires up.

### home (3 alternate home layouts + shared pieces)
**Purpose:** The primary product-discovery surface. The codebase ships **three interchangeable, fully-built home page designs** — a rebuild only needs one, but all three currently exist and work.
**Screens/Flows (default theme, `home_screens.dart`):**
- Announcement banner (config-driven, dismissible).
- Search bar.
- Promotional banner carousel.
- Horizontal category icon list.
- Flash Deals list (countdown-timed).
- Featured Deals list.
- Clearance Sale list.
- A single mid-page footer-style banner.
- Featured Products grid.
- Top Sellers row (multi-vendor only).
- Recommended Products (personalization row).
- Latest Products list.
- Brand list.
- Per-configured-category product rows ("home categories" — admin picks which categories get their own row).
- Footer banner slider.
- Sticky product-filter popup + infinite-scrolling "all products" feed at the very bottom.
**Screens/Flows (`theme_aster`, `theme_fashion`):** Two alternate, differently laid-out home experiences (~500 lines each) selected the same way — same underlying data/controllers, different visual arrangement and component set (e.g., different hero treatment, different section ordering). Not experimental — fully wired into the dashboard's theme switch.
**Key capabilities/business rules:** Home content is driven almost entirely by backend config (which sections show, which categories get their own row, banner content) — very little is hardcoded layout.
**Dependencies:** none beyond standard product/category/banner endpoints.

### category
**Purpose:** Browse the category tree.
**Screens/Flows:** Grid/list of top-level categories; tapping drills into a "brand & category product" listing (shared with brand browsing — see `product` module) showing sub-categories plus an "All Products"/"View All Products" toggle depending on whether sub-categories exist.
**Key capabilities/business rules:** Supports nested sub-categories (used from the header/mega-menu equivalent too).
**Dependencies:** none.

### brand
**Purpose:** Browse the brand directory.
**Screens/Flows:** All-brands list with a sort menu (Top Brand / A→Z / Z→A) and a filter icon.
**Dependencies:** none.

### shop
**Purpose:** Individual vendor storefronts and the directory of all vendors (multi-vendor only).
**Screens/Flows:**
- **All-shops directory** — filterable by New Sellers / All Sellers / Top Sellers, paginated list, each entry showing rating/product count.
- **Individual shop screen** — two tabs: **Overview** (featured/recommended products for that seller) and **All Products** (full catalog with its own search bar and product-filter dialog).
- **Shop overview screen** — standalone featured/recommended section, reusable outside the tabbed shop view.
**Key capabilities/business rules:** Vendor vacation mode and "temporarily closed" status are both modeled and surface as blocking states elsewhere (cart, chat) — a closed/on-vacation shop can't be checked out against.
**Dependencies:** multi-vendor `business_mode`; not meaningful in single-vendor mode.

### search_product
**Purpose:** Global product search.
**Screens/Flows:** Search field with locally-persisted, clearable search history; popular-tags suggestion list; results grid; filter/sort state indicators.
**Key capabilities/business rules:** Filter dialog (shared `product_filter_dialog_widget`) supports: product type (physical/digital), category, brand, author/creator, publishing house, price min/max range, plus a sort dropdown. "Select brand or category first" / "select author or publishing house first" guard messages prevent nonsensical filter combinations.
**Dependencies:** none.

### banner
**Purpose:** Tap-through landing page for promotional banners/offers.
**Screens/Flows:** Single "Offers" product list screen (the destination when a home banner is tapped).
**Dependencies:** none.

### deal
**Purpose:** Time-boxed and merchandising-curated deal listings.
**Screens/Flows:** **Flash Deal** screen (countdown-timed, own product grid) and **Featured Deal** screen (curated list, no countdown).
**Dependencies:** none.

### clearance_sale
**Purpose:** Clearance/liquidation listings, both store-wide and per-shop.
**Screens/Flows:** All-clearance-products screen (with its own in-page search) and a shop-scoped clearance variant.
**Dependencies:** none.

---

## 3. Product & Catalog

### product
**Purpose:** Shared product-listing surfaces reused across category, brand, and "view all" contexts.
**Screens/Flows:** `brand_and_category_product_screen` (the shared drill-down grid used by both category and brand browsing) and a generic `view_all_product_screen`.
**Dependencies:** none.

### product_details
**Purpose:** The single-product page — the most feature-dense screen in the app.
**Screens/Flows:**
- Image carousel + a dedicated full-screen product-image viewer screen.
- Optional embedded YouTube video widget.
- Title block: name, rating stars, review count, order count, wishlist count, stock-availability text, color swatches, and choice-option chips (e.g. size) when variations exist.
- "Promise" trust-badge widget (e.g. authenticity/quality claims — content is config/CMS-driven).
- Specification tab and a standalone full specification screen.
- Review-and-specification tabbed section; review list pulled from the `review` module.
- Shop-info widget (seller card) linking into the `shop` module.
- Related-products row and a "more from this shop" row.
- Sharable deep-link generation (share sheet).
- Sticky bottom add-to-cart bar, disabled with an explicit "this shop is closed now" message if the seller is on vacation/closed; success toast on add.
- Digital-product specific fields: author list and publishing-house list rendered as tappable filter chips when present (this template also supports ebook/digital products, not just physical).
**Key capabilities/business rules:** Variation availability is computed from the presence of *both* colors and choice-options together; a product with only one of the two doesn't trigger the variation-picker UI path.
**Dependencies:** none beyond product/review APIs.

### review
**Purpose:** Product review display and submission.
**Screens/Flows:** Dedicated review list screen (title shows live count); review submission is actually triggered from Order Details (post-delivery), not from the product page directly.
**Key capabilities/business rules:** A review can be created or *updated* — order details shows "Review" vs. "Update review" depending on whether one already exists for that line item. Sellers can reply to reviews (`review_reply_widget` exists in order_details).
**Dependencies:** none.

### compare
**Purpose:** Side-by-side product comparison.
**Screens/Flows:** Comparison table (Price / Color / Brand / Ratings rows across selected products), add/remove per product, "Clear All" with a confirmation bottom sheet.
**Dependencies:** none.

### wishlist
**Purpose:** Saved-for-later products.
**Screens/Flows:** Wishlist grid with its own in-page search field.
**Dependencies:** requires login (guest wishlist is not supported the way guest cart is).

### restock
**Purpose:** "Notify me" requests for out-of-stock products.
**Screens/Flows:** List of active restock requests per product, with a "Clear All" action.
**Dependencies:** triggers a push/notification (`product_restock_update` type) when the item is back — see Notifications.

---

## 4. Cart & Checkout

### cart
**Purpose:** Multi-vendor shopping cart — genuinely the most business-rule-dense module in the app.
**Screens/Flows:** Cart grouped visually by seller, each seller group individually checkable (select/deselect all items from one seller at once); running totals (subtotal, discount, tax-inclusive total).
**Key capabilities/business rules (all enforced before checkout is allowed):**
- Per-seller **minimum order amount** — if a seller's selected-item subtotal is under their configured minimum, checkout is blocked, an explicit message names the amount and the seller, and the view auto-scrolls to that seller's group.
- **Stock validation** — any checked physical-product line exceeding current stock blocks checkout with a "stock out product in your cart" message.
- **Seller availability guard** — a seller currently on vacation or temporarily closed blocks checkout for their items, with the same vacation-window logic (`vacation_status`, `vacation_start/end_date`, `vacation_duration_type`) used on the shop screen.
- **Shipping-method awareness** — behavior branches on the store-wide `shippingMethod` config: `sellerwise_shipping` (each seller's group gets its own shipping-method selector, and an unselected order-wise shipping method on a seller blocks checkout) vs. a single order-level shipping flow.
- **Free-delivery threshold tracking** — per seller, if the checked items cross that seller's free-delivery order-amount threshold, the shipping saving is shown/credited.
- At least one item must be selected to proceed ("select at least one product").
- Cart persists across guest → logged-in transition via server-side merge (see auth).
**Dependencies:** none beyond product/shop config.

### checkout
**Purpose:** Order placement — address, shipping, coupon, payment method, and final confirmation.
**Screens/Flows:**
- Shipping-address selector (required) and billing-address selector (required specifically for digital-product orders even if a shipping address isn't otherwise needed).
- Coupon apply widget + a coupon-picker bottom sheet.
- Order note free-text field.
- Order summary breakdown: subtotal (with item count), shipping fee, discount, coupon voucher amount, tax, referral discount, and a grand total that's labeled "inc. VAT/tax" when the store's tax-inclusive-pricing flag is on.
- Payment-method bottom sheet (see below) → order placement → confirmation dialog/bottom sheet.
- Guest checkout: a guest-mode contact-information picker widget collects name/phone/email inline, plus a "create an account" upsell widget offered post-guest-order.
- "Change amount" widget — for cash-on-delivery, lets the buyer specify what note denomination they'll pay with so the delivery person can bring correct change.
- Digital product orders route to a distinct `digital_payment_order_place_screen`.
**Payment methods wired (chosen via `payment_method_bottom_sheet_widget`):**
- **Cash on Delivery** (default-selected).
- **Wallet** (checks balance, blocks with "insufficient balance" if short).
- **Pay via Online** — a dynamic list of configured gateways; the six store-side gateways referenced across the app are **Stripe, PayPal, Razorpay, Paystack, Flutterwave**, plus any others the backend exposes (rendered generically, not hardcoded per-gateway UI beyond icon/name).
- **Pay Offline** — routes into the `offline_payment` module (see below).
**Key capabilities/business rules:** Order placement is blocked with specific messages for: no shipping address selected, no billing address selected (digital products), and (carried over from cart) any of the cart-level guards that weren't already resolved.
**Dependencies:** at least one payment method must be configured server-side or checkout has nothing to offer.

### offline_payment
**Purpose:** Manual/bank-transfer-style payment where the buyer submits proof rather than paying through a live gateway.
**Screens/Flows:** Horizontal card list of admin-configured offline methods (bank transfer, etc.) with instructional helper text; a form to submit payment details/reference (also reused for post-order due-amount payments — see Order Details).
**Dependencies:** admin must configure at least one offline method for this to have any content.

### coupon
**Purpose:** Browse/apply discount codes.
**Screens/Flows:** Coupon list screen, plus the in-checkout apply widget and bottom-sheet picker.
**Dependencies:** none.

### shipping
**Purpose:** Shipping-method selection logic used from cart/checkout.
**Screens/Flows:** No dedicated screen — a bottom sheet (`shipping_method_bottom_sheet_widget`) presenting the available delivery methods for a given seller/order, with a "no shipping method available" empty state.
**Dependencies:** consumed by `cart` and `checkout`.

### vat_tax
**Purpose:** Tax/VAT configuration and calculation support consumed by cart/checkout/product-details (no dedicated screen).
**Dependencies:** store-level tax config (inclusive vs. exclusive display, tax model/type per product).

---

## 5. Orders & Post-Purchase

### order
**Purpose:** Order history list.
**Screens/Flows:** Three-tab list — **Running**, **Delivered**, **Canceled**.
**Dependencies:** login required (guest orders are tracked via the separate guest-tracking flow, not this list).

### order_details
**Purpose:** Full detail, status, and post-purchase actions for a single order — the richest post-purchase surface in the app.
**Screens/Flows/widgets:**
- Payment info: status, method, and (when applicable) a second "order edit" payment block — see below.
- Ordered product list with variation info, quantity, per-line pricing.
- Order note display.
- Shipping and billing info, seller section (multi-vendor orders broken out by seller).
- Delivery-man info, including a "picture uploaded by delivery man" proof-of-delivery photo when present, and a delivery-man review dialog post-delivery.
- Per-product **review** submission/update button (post-delivery).
- Per-product **refund request** flow (gated to `delivered` orders): request form with reason, image attachments (`refund_image_selection_widget`), a change-log of the refund's status history, and a "refunded details" result view.
- **Order-edit due/return workflow** — if a seller edits an order after placement, the customer sees either a "pay due bill" prompt (with its own payment-method flow, including its own offline-payment sub-screen) or an "amount to be returned" notice, each tracked with independent payment/return status labels.
- Cancel-order dialog, and a "cancel & support center" widget offered when direct cancellation isn't allowed (routes to support instead).
- In-order chat/call access to the seller (`cal_chat_widget`).
- **Guest order tracking** (separate screen, no login) — order ID + phone number lookup.
**Key capabilities/business rules:** Refund eligibility is computed from order status (`delivered`), not just a flag — a hard gate in code, not just a UI hint.
**Dependencies:** none beyond order/refund APIs.

### tracking
**Purpose:** Visual order-status timeline.
**Screens/Flows:** Five-step tracker — Order Placed → Order Confirmed → Preparing for Shipment → On the Way → Delivered — plus a distinct visual state for canceled orders.
**Dependencies:** none.

### refund
**Purpose:** Backing logic/widgets for the refund flow (no dedicated top-level screen — surfaced entirely inside Order Details): request form, image attachment picker, status change-log, and refunded-details result view.
**Dependencies:** order must be `delivered`.

### reorder
**Purpose:** "Buy again" — recreates the cart from a previous order in one action (no dedicated screen; a controller method invoked from order history/details).
**Dependencies:** none.

---

## 6. Auction / Livestock Bidding

This is the largest single feature cluster (10 modules) and is fully wired, config-gated, real-money functionality — not a demo stub. It is highly relevant to MeatSoko's actual business (livestock/product auctions) and should be treated as a first-class rebuild target, not an afterthought.

**Master gate:** the entire cluster is hidden — center swap button, both auction dashboard tabs, and every auction menu entry — unless `isAuctionFeatureEnabled` is true in store config. A secondary flag, `isActiveAuctionForCustomer`, separately gates whether customers may *create* auction listings (as opposed to just bidding).

### auction_home
**Purpose:** Auction discovery — the auction-mode equivalent of the shopping home page.
**Screens/Flows:** Tabbed layout — an **Explore** tab plus one tab per auction category (tabs and per-tab scroll position both persist across navigation). Explore tab sections: **Ending Soon**, **Trending Auction Products**, **Recently Viewed**, **Upcoming Auctions**, and a **Category** section (grid of categories with live product counts, "View All" per category). A dedicated search entry point (see `auction_search`).
**Dependencies:** none beyond auction endpoints.

### auction_category
**Purpose:** Auction-specific category browsing (parallel structure to the regular `category` module, kept separate because auction listings have their own taxonomy).
**Dependencies:** none.

### auction_details
**Purpose:** The single-auction page and the live bidding interaction itself.
**Screens/Flows (participation — bidder side):**
- Auction ID, live status label, countdown timer to auction end.
- Current highest bid (falls back to starting price pre-bid), total bid count, and an **auction insights** panel (total bids, average bid increase).
- **Live participant bidding list** — a real-time-feeling feed of bids placed by other participants.
- Similar-products and "more auctions from this seller" rows.
- Post-win: a **winner banner** with its own claim-deadline countdown, and a **"Claim Product"** action that hands off into `auction_checkout`.
**Screens/Flows (creator — the customer who listed the item):** a parallel `creator_auction_details_screen` for managing their own listing (status, bids received, admin-commission payment flow via `payment_method_bottom_sheet_widget` built for this purpose).
**Key capabilities/business rules — bidding mechanics (in `auction_bid_action_widget`):**
- A configured **minimum increment amount** governs every subsequent bid; the widget computes the rollback/minimum-rebid amount as `second-highest bid + increment` (or the starting price if there's no second bid yet).
- Five **suggested quick-bid amounts** are generated as `base + (increment × step)`.
- Custom bid entry is also supported alongside the quick-bid chips.
- **"Rise bid"** — raise your own existing bid.
- **"Withdraw bid"** — with an explicit "are you sure" confirmation dialog.
- **Auction entry fee**: many auctions require an upfront, non-refundable-looking entry fee before a bid can even be placed. The entry-fee payment flow has its own mini payment-method chooser: **wallet** (with balance display, an "Apply"/"Applied" toggle, and an insufficient-balance state), **pay via online** (gateway list), and **pay offline** (manual payment, producing a "waiting for payment verification" pending state until admin confirms).
- Auction/bid lifecycle states surfaced in the UI: live, won, claimed, lost, claim-expired, participated — see `my_bids_screen` tabs below for the authoritative state list.
**Dependencies:** wallet balance API; same payment-gateway config as regular checkout.

### auction_checkout
**Purpose:** Post-win purchase completion (parallel to the regular `checkout` module, auction-specific).
**Screens/Flows:** Shipping/billing address selection (own saved-address list screens, separate from the regular ones), auction order summary (subtotal, shipping fee, tax, total — same inc.-VAT labeling convention as regular checkout), its own offline-payment sub-screen, and a "claimed successfully" confirmation.
**Dependencies:** none beyond addresses/payment.

### create_auction (+ ai)
**Purpose:** Lets a **customer** (not just a vendor) list an item up for auction — genuine consumer-to-consumer/consumer-to-marketplace listing creation.
**Screens/Flows:** Three-tab wizard — **General Info** → **Auction Info** → **SEO**, each tab itself multi-language-aware (a language sub-tab per store-enabled locale). Supports create, edit-existing, and **relaunch** (re-list an auction that ended unsold) modes.
**Key capabilities/business rules:**
- **AI-assisted content generation** at every step, via the `ai` module: generate description from title, generate the whole "general setup" section, generate shipping-policy text, generate auction-info fields, generate SEO fields, generate/suggest a title, and an image-analysis assist (`auction_image_analyze_bottom_sheet`) — all guarded with "enter a product name/description first" validation before firing.
- A generation-count widget suggests these AI calls are rate-limited/metered per listing.
**Dependencies:** an AI backend/provider must be configured (mirrors the web backend's `Modules/AI`) for the AI-assist buttons to do anything; otherwise the manual-entry path still works standalone.

### auction_list
**Purpose:** Moderation-facing queue of a customer's **pending** (not-yet-approved) auction submissions.
**Screens/Flows:** "Auction Request" list with a delete-with-confirmation action per pending item.
**Dependencies:** none.

### user_created_auction_list
**Purpose:** "My Auctions" — the customer's approved/live listings (distinct from the pending queue above).
**Screens/Flows:** List with per-item **cancel** and **delete** actions, each with its own confirmation dialog.
**Dependencies:** none.

### auction_search
**Purpose:** Search within auctions (parallel to `search_product`).
**Screens/Flows:** Same pattern as product search — persisted/clearable search history, popular tags, results grid, "no data found" empty state.
**Dependencies:** none.

### auction_transaction
**Purpose:** Financial reporting for a customer's own auction selling activity.
**Screens/Flows:** **Auction Sales Report** (stat cards — totals/earnings) and **Auction Transaction List** (searchable by auction ID).
**Dependencies:** none beyond auction-transaction API.

### auction_dashboard_summary
**Purpose:** Aggregate counts feeding badges across the More screen and dashboard (no dedicated screen) — total my bids, total saved auctions, total my auctions, total pending auction requests, etc.
**Dependencies:** consumed wherever auction badge counts are shown.

### auction (My Bids / My Activity / Saved)
**Purpose:** The bidder's personal auction hub.
**Screens/Flows:**
- **My Bids** — six status-filter tabs: **Participated, Live, Won, Claimed, Lost, Claim Expired**. This is the authoritative bid-lifecycle state list for the whole cluster.
- **My Auction Activity** — recently-viewed auctions (shown with a live total count in the app bar).
- **Saved Auctions** — the auction equivalent of wishlist.
**Dependencies:** login required for all three (each shows a "log in to view" prompt otherwise).

---

## 7. Account, Wallet & Loyalty

### profile
**Purpose:** Personal info management and account deletion.
**Screens/Flows:** Edit first name, last name, email, phone, and password/confirm-password; email- and phone-verification status shown inline (tooltip warning when unverified); **self-service account deletion** (`delete_account_bottom_sheet_widget` — required by app store policies).
**Key capabilities/business rules:** "Change something to update" guard prevents a no-op save; full field-level required-ness and password-length validation before submit.
**Dependencies:** none.

### address
**Purpose:** Saved delivery/billing addresses.
**Screens/Flows:** Address list (edit/delete per entry, each tagged as shipping or billing), add/edit address form with a **Google Map picker** (drop-pin, `GoogleMapController`) alongside manual contact-name/phone/email/city/zip fields, and an address-**label** picker (Home/Office/etc., "Label us" prompt).
**Key capabilities/business rules:** Shipping and billing addresses are modeled as genuinely separate lists (`saved_address_list_screen` vs. `saved_billing_address_list_screen`), each independently usable during checkout.
**Dependencies:** Google Maps API key.

### location
**Purpose:** One-off delivery-location selection (distinct from saving a full address record) — used e.g. for a delivery-radius/area check before checkout.
**Screens/Flows:** Full-screen map with a search dialog and a "Select Location" confirm action.
**Dependencies:** Google Maps API key, geocoding.

### wallet
**Purpose:** In-app store-credit balance.
**Screens/Flows:** Balance display, transaction history list, **Add Funds** flow that opens an in-app browser to a payment gateway and handles success / failure / cancelled outcomes as distinct confirmation dialogs.
**Key capabilities/business rules:** Wallet balance is spendable directly at checkout (both regular and auction-entry-fee checkouts check and can apply it).
**Dependencies:** a payment gateway configured for top-ups.

### loyaltyPoint
**Purpose:** Points-based loyalty program.
**Screens/Flows:** Points balance, a "Convert to Currency" action (turns points into spendable wallet/store credit), and a filterable points-history list.
**Dependencies:** none.

### refer_and_earn
**Purpose:** Referral program.
**Screens/Flows:** Personal referral code display with copy-to-clipboard and native share, a short 3-step explainer ("invite friends" → "they register with special offer" → "you earn"), config-gated visibility (only shown when referral earning is enabled).
**Key capabilities/business rules:** The referral code can also be deep-linked directly into sign-up (`signUpAuth` route pre-fills the refer code field).
**Dependencies:** none.

### transaction
**Purpose:** Shared transaction-history data/model layer consumed by `wallet` and `auction_transaction` (no dedicated top-level screen of its own).
**Dependencies:** none.

---

## 8. Support & Content

### chat
**Purpose:** In-app messaging with sellers (and, separately, delivery staff on active orders).
**Screens/Flows:** **Inbox** (thread list with in-page search, guest users blocked with a "log in to communicate with vendors" prompt) and the **conversation screen** itself, plus a full-screen media viewer for shared images.
**Key capabilities/business rules:** Attachment limits are enforced client-side with specific messages: a max file *count* per send, a max *total* size per conversation send, and a max *single-file* size — all three configured via `AppConstants` limits, not hardcoded per-message. The conversation screen shows a live shop-open/closed banner inline so a buyer knows if a reply will be prompt.
**Dependencies:** none beyond chat API; file upload limits are app-constant configurable.

### support
**Purpose:** Formal support-ticket system (distinct from ad-hoc seller chat).
**Screens/Flows:** Ticket list ("Add New Ticket" entry point), new-ticket form (subject, description, priority — all required, validated before submit), and a ticket conversation/thread screen.
**Dependencies:** none.

### contact_us
**Purpose:** Simple contact form.
**Screens/Flows:** Full name, email, phone, subject, message fields, single submit.
**Dependencies:** none.

### blog
**Purpose:** Content/blog reading.
**Screens/Flows:** Blog screen (renders a backend-provided blog URL, effectively a wrapped web view of the storefront's blog module).
**Dependencies:** backend blog module must be enabled for content to exist.

### more
**Purpose:** The account/settings hub — a left icon-rail + detail-pane layout (tablet-friendly), and the single largest menu surface in the app.
**Screens/Flows:** Left rail: Profile, Address, Notifications (with unread badge combining general + auction notification counts), Categories, Inbox, Contact Us, Settings, and a Logout action (confirmation bottom sheet) at the rail's foot. Right-hand detail pane, grouped into sections:
- **Bidding Activity** (auction-gated): My Bids, Saved Auctions — each badge-counted from the auction dashboard summary.
- **My Auctions** (auction-gated, creation-gated separately): Create Auction, All Auctions, Auction Request List, Auction Sales Report, Auction Transaction History.
- **General:** Coupons, Compare Products, Refer & Earn, Order History, Track Order, Wallet, Loyalty Points (with live point balance in the label), Offers, Cart, Wishlist, Restock Requests, Blog.
- **Help & Support:** Support Ticket, Terms & Conditions, Privacy Policy, Refund Policy, Return Policy, Cancellation Policy, Shipping Policy, FAQ, About Us, plus any additional admin-authored business pages appended dynamically.
- Dark-mode toggle and current app version display at the bottom.
**Key capabilities/business rules:** Any not-logged-in tap on a personal item (profile, my bids, etc.) surfaces a shared "not logged in" bottom sheet with an inline login path that returns the user to exactly where they tapped from, rather than bouncing them to a separate login page and losing context.
**Dependencies:** none beyond the modules it links to.

### setting
**Purpose:** App-level preferences (a subset also duplicated/accessible from the More screen's dark-mode toggle).
**Screens/Flows:** Dark-theme switch, language picker (bottom sheet), currency picker (bottom sheet, shows currently active currency name inline).
**Dependencies:** none.

---

## 9. Notifications

### notification
**Purpose:** In-app notification center.
**Screens/Flows:** Two tabs — **General** and **Auction** — each a separate list/feed with its own unread state.
**Dependencies:** notification API; badge counts combine both feeds and are also surfaced on the More screen's rail icon.

### push_notification (infrastructure, not a feature module)
**Purpose:** Converts incoming Firebase Cloud Messaging payloads into an in-app deep-link.
**Key capabilities/business rules:** A single `NotificationBody` model carries: `type`, `order_id`, `product_id`/`slug`, `auction_id`/`auction_slug`, `message_key`, `status`, `title`, `image`. The splash-screen routing logic (see §1) is the single source of truth for how each `type` maps to a destination screen — reproduce that mapping exactly to avoid silently-broken deep links.
**Dependencies:** Firebase Cloud Messaging (currently misconfigured — mismatched `google-services.json`, see `xdocs/mobile_apps.md`); `flutter_local_notifications` for foreground display.

---

## 10. Platform / Infrastructure

### localization
**Purpose:** Multi-language UI.
**Languages bundled:** English (`en`), Arabic (`ar`), Bengali (`bn`), Spanish (`es`), Hindi (`hi`). **No Swahili** despite this being a Kenyan storefront — worth deciding on explicitly for a rebuild.
**Key capabilities/business rules:** Arabic triggers full RTL layout flip (`isLtr` flag driven purely off `languageCode == 'ar'`); every other bundled language stays LTR.

### theme
**Purpose:** Light/dark mode.
**Key capabilities/business rules:** Two complete, independent theme definitions (`light_theme.dart`, `dark_theme.dart`) plus a small custom-colors extension file; toggled from both the Settings screen and the More screen, state held in a dedicated `ThemeController` and persisted locally.

### local cache (drift / `data/local`)
**Purpose:** Lightweight local database (via the `drift` package) used specifically as an API-response cache keyed by endpoint — most visibly the `/api/v1/config` response, read on splash before any network call so the app can route instantly on repeat opens and fall back gracefully offline. This is a response cache, not a full offline data-entry store — there's no offline order creation, cart editing, etc.

### maintenance
**Purpose:** Full-screen maintenance-mode notice.
**Screens/Flows:** Title, body copy, and a "call us" contact prompt; observes app lifecycle (`WidgetsBindingObserver`) so it re-checks maintenance status when the app resumes from background, rather than trusting a stale check from before backgrounding.
**Dependencies:** store-wide maintenance-mode config flag; can be scoped so maintenance mode applies to the customer app specifically without also taking down web/vendor.

### update
**Purpose:** Forced-update gate.
**Screens/Flows:** Single screen — "your app is deprecated" message and an "Update Now" button that launches the platform app-store URL.
**Key capabilities/business rules:** Triggered by comparing the server-configured minimum version (separately for Android and iOS) against the app's own `AppConstants.appVersion`; blocks all further navigation until satisfied — there is no "skip" path once triggered.

### common / basewidget (shared UI infrastructure — 65 files)
Not a feature in itself, but the shared vocabulary every module above is built from — a rebuild should budget for reproducing these as reusable primitives rather than one-off duplicating them per screen: custom app bars (including an "expanded" variant), custom buttons (with built-in loading state), custom text fields (with password-visibility toggle, country-code picker integration, validators), custom snackbars (success/warning/error variants), the shared product-filter dialog, a "not logged in" bottom sheet (used everywhere an action requires auth), a generic "no internet / no data" screen wrapper, shimmer loading placeholders per major screen type, paginated list view helper, and an auction-specific feature-banner widget.

---

## Nothing here is optional to notice — full module checklist

Every module below is covered in this document. Use this list to visually confirm nothing was dropped in a rebuild scoping pass.

**Onboarding / Auth:** splash · onboarding · auth
**Home / Discovery:** dashboard · home · category · brand · shop · search_product · banner · deal · clearance_sale
**Product / Catalog:** product · product_details · review · compare · wishlist · restock
**Cart / Checkout:** cart · checkout · offline_payment · coupon · shipping · vat_tax
**Orders:** order · order_details · tracking · refund · reorder
**Auction:** auction · auction_home · auction_category · auction_details · auction_checkout · create_auction · ai · auction_list · user_created_auction_list · auction_search · auction_transaction · auction_dashboard_summary
**Account:** profile · address · location · wallet · loyaltyPoint · refer_and_earn · transaction
**Support / Content:** chat · support · contact_us · blog · more · setting
**Notifications:** notification · push_notification
**Platform:** localization · theme · local cache (drift/data/local) · maintenance · update · common/basewidget

**57 `lib/features/*` modules (all named individually above, `maintenance` and `update` counted once each under Platform) + 5 cross-cutting infrastructure areas outside `lib/features/` (localization, theme, local cache/drift, push_notification, common/basewidget) = everything in scope is represented above.**
