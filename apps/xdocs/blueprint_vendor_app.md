# Vendor App — Rebuild Blueprint

**What this document is:** a complete feature inventory of the current Vendor app (`sixvalley_vendor_app`, the seller-facing Flutter app in this repo, part of the stock licensed 6valley template — see `xdocs/mobile_apps.md` for that context). It exists so a team rebuilding this app on any stack can reimplement every capability the current app has, without silently dropping something.

**What this document is not:** a recommendation of what MeatSoko *should* keep. This describes current template behavior as a completeness baseline. Some of it (digital products/publishing houses, multi-language support beyond English, auction bidding) may or may not be relevant to MeatSoko's actual business — that's a product decision for later, not something this document resolves.

**One confirmed gap in the current app itself:** `vat_management/screens/expense_report_screen.dart` is a literal stub — its entire body is a screen reading "------------Need Design----------". It's wired into navigation (Vat Management → Reports → presumably an expense report entry) but was never built. Flagged inline below too.

---

## Table of Contents

1. [Onboarding & Auth](#1-onboarding--auth) — splash, auth, maintenance, update
2. [Home & Navigation](#2-home--navigation) — dashboard, home, menu
3. [Catalog Management](#3-catalog-management) — addProduct, ai, product, product_details, barcode, clearance_sale, restock
4. [Order Fulfillment](#4-order-fulfillment) — order, order_details, order_edit
5. [Point of Sale](#5-point-of-sale-pos)
6. [Auction (Seller Side)](#6-auction-seller-side)
7. [Finance & Wallet](#7-finance--wallet) — wallet, transaction, bank_info, vat_management, coupon
8. [Staff & Delivery Management](#8-staff--delivery-management) — delivery_man
9. [Shop & Business Settings](#9-shop--business-settings) — shop, settings, shipping
10. [Customer Interaction](#10-customer-interaction) — chat, review, refund
11. [Account & Profile](#11-account--profile) — profile
12. [Support & Misc](#12-support--misc) — emergency_contract, more, language, notification
13. [Platform / Infrastructure](#13-platform--infrastructure)
14. [Completeness checklist](#14-completeness-checklist)

---

## 1. Onboarding & Auth

### `splash`
**Purpose:** app boot sequence — decides where to route the user before anything else is visible.
**Screens/Flows:**
- Splash screen shows the logo while the app fetches remote config (`ConfigModel`) and business pages.
- Routes to one of: **Update screen** (forced update, if app version is below the admin-configured minimum), **Maintenance screen** (if vendor-app maintenance mode is on server-side), or the **Auth/Dashboard** flow depending on login state.
**Key capabilities/business rules:** maintenance mode and forced update are both entirely server-driven config flags (`maintenanceModeData.selectedMaintenanceSystem.vendorApp`, app version check) — the client has no local override.
**Dependencies:** backend config endpoint; no local/offline cache layer in this app (unlike the User app's `drift` DB — this app is remote-data-only).

### `maintenance`
**Purpose:** full-screen block shown when the vendor app is put into maintenance mode by the admin.
**Screens/Flows:** single screen — maintenance title, maintenance body message (both server-configurable text), and a "call us" contact number for urgent queries.
**Dependencies:** server config.

### `update`
**Purpose:** forces the vendor to update the app when running a version below the admin-configured minimum.
**Screens/Flows:** single screen — "your app is deprecated" message, "Update Now" button that deep-links to the app store listing.
**Key capabilities/business rules:** blocking — no way to bypass and continue with the old version.

### `auth`
**Purpose:** login, self-service seller registration, password recovery, OTP verification.
**Screens/Flows:**
- **Login screen** (`login_screen.dart`): email + password fields, "remember me" toggle (persists credentials locally), "forgot password?" link, self-registration link (only shown if `seller_registration` is enabled server-side), terms & conditions link. Validates: email non-empty, valid email format, password non-empty, password ≥ 6 chars.
- **Registration screen** (`registration_screen.dart`): a 2-tab wizard (not free navigation — must complete tab 1 before tab 2 unlocks):
  - Tab 1 (personal info): first name, last name, profile image (required), email (validated), phone with country-code picker (≥8 digits), password (≥8 chars, must pass a password-strength check), confirm password (must match).
  - Tab 2 (shop info): shop name, shop address, shop logo (required image), shop banner (required image), secondary banner (required only if the active theme isn't "default"), business TIN number, TIN expiry date, TIN certificate file upload (max 2MB). Requires accepting Terms & Conditions checkbox before Submit is enabled.
  - On success: shows a "Registration Successful" modal (implies pending admin approval, not instant activation).
- **Forgot password screen**: verification method is server-config-driven — either phone/OTP or email/reset-link, decided by `forgotPasswordVerification` config. Phone path uses a country-code picker; email path sends a recovery link and shows a "sent" confirmation dialog.
- **OTP verification screen**: 6-digit pin entry with a countdown-driven resend timer (`otpResendTime` from config), leads into a reset-password step on success.
**Key capabilities/business rules:** registration is a formal application, not instant account creation — the "shop application" title and success dialog imply admin review before the seller can log in. Self-registration can be disabled entirely server-side.
**Dependencies:** country-code picker data, backend config for verification method and OTP timing.

---

## 2. Home & Navigation

### `dashboard`
**Purpose:** the app's root shell — bottom navigation and page-switching container.
**Screens/Flows:**
- Bottom nav: **Home**, **My Order**, **Refund**, **Menu** (the 4th tab opens a bottom-sheet menu rather than navigating, see `menu` below).
- On load, prefetches: seller profile, digital-product authors/publishing houses, category list, cart data, shop info, transaction list, payment info list, auction lists (if enabled), and checks the AI generation limit (if AI feature is active).
- Back button on a non-Home tab returns to Home instead of exiting; on Home, back shows an "exit app?" confirmation dialog.
- A separate **`NavBarScreen`** (in the same module) is the alternate shell used specifically for POS mode, with its own bottom nav: **POS**, **My Order**, **Products**, **Menu**.

### `home`
**Purpose:** the actual dashboard content shown under the Home tab — an operational overview screen.
**Screens/Flows:** a single scrollable dashboard with, top to bottom:
- App bar with a notification bell showing a combined unread badge (general notifications + auction notifications, summed only if the auction feature is enabled).
- Ongoing orders widget and Completed orders widget (quick-glance counts/lists).
- Low-stock ("stock out") product alert card, shown only when such products exist.
- Revenue chart (with a filter: overall / by period).
- Top selling products list.
- Most popular products list.
- Top delivery man leaderboard — hidden entirely if the shop's shipping method is `inhouse_shipping` (i.e., only relevant when using platform-wide delivery staff).
- Pull-to-refresh reloads everything.
**Dependencies:** many parallel controllers/endpoints (orders, products, bank/revenue info, delivery man, notifications, reviews).

### `menu`
**Purpose:** the full navigation hub, presented as a bottom sheet grid (opened from the dashboard's 4th nav tab).
**Screens/Flows:** a 4-column icon grid linking to: Profile, My Shop, Add Product, Products, Reviews, Coupons, Delivery Man, **POS** (only if both the platform and this specific vendor have POS enabled), Settings, Restock, Clearance Sale, Wallet, Inbox (chat), VAT Management, **Auctions** (only if the auction feature is enabled platform-wide or specifically for this vendor), Bank Info, then conditionally: Terms & Conditions, About Us, Privacy Policy, Refund Policy, Return Policy, Cancellation Policy (each shown only if that business page exists server-side), Logout (with confirmation dialog), and an app-version display tile.
**Key capabilities/business rules:** this is the authoritative feature list for the app — every top-level feature is reachable from here. POS and Auction visibility are both dual-gated (platform config AND per-vendor flag).

---

## 3. Catalog Management

### `addProduct`
**Purpose:** create and edit product listings — the most complex single flow in the app.
**Screens/Flows:** a 3-tab wizard (`AddProductTabView`), each tab passing its collected data forward to the next as the vendor advances (data isn't lost switching tabs):
- **Tab 1 — General Info** (`add_product_screen.dart`): product type toggle (Physical vs Digital — Digital only available if the platform's `digital_product_setting` is on), category/subcategory selection, brand selection (or "no brand"), unit selection, product name, product code/SKU, description (with an AI "generate" assist button), thumbnail image upload, additional gallery images upload, YouTube video link. Digital products additionally collect: digital sub-type (e.g. "ready after sell" vs. made-to-order), author(s) and publishing house(s) (multi-select, chip-style — this is inherited e-book/digital-goods functionality from the template).
- **Tab 2 — Variations** (`add_product_next_screen.dart`): enable/configure color variants and other attributes (e.g. size); per-variant SKU, price, stock quantity, and a per-color image; unit price, minimum order quantity, shipping cost, discount amount, tax model + tax rate selection. For digital products: per-variant file upload with file-type/extension management (a single digital product can offer multiple deliverable file types).
- **Tab 3 — SEO** (`add_product_seo_screen.dart`): meta title, meta description, meta image, product tags, embedded video link/image preview setup. Submit here creates or updates the product.
**Key capabilities/business rules:** products go through an **admin approval workflow** — status values seen in `product_details` are `new_request`, `approved`, `denied` (with a `denied_note` shown to the vendor). A newly added or edited product is not necessarily live immediately. AI-assisted content generation is available throughout (see `ai` below) and is usage-limited.
**Dependencies:** category/brand/unit reference data, tax configuration, AI service (optional), image upload.

### `ai`
**Purpose:** AI-assisted product listing creation — upload a photo and have the AI generate a title, description, suggested price, variation setup, and SEO metadata.
**Screens/Flows:** a bottom-sheet flow (`AiGeneratorBottomSheet` → `image_analyze_bottom_sheet` → `generate_title_bottom_sheet`) invoked from the Add Product flow: upload/select an image, AI analyzes it, generates a title and other suggested content, which the vendor can review/accept before it populates the product form fields.
**Key capabilities/business rules:** generation is quota-limited per vendor (`generateLimitCheck()` is called before every generation action, and a remaining-count indicator is shown in the Add Product app bar). Gated entirely behind the platform's `isAiFeatureActive` config flag.
**Dependencies:** a configured AI provider on the backend (see the web backend's `Modules/AI`); image upload.

### `product`
**Purpose:** browse, filter, and manage the vendor's existing product catalog.
**Screens/Flows:**
- **Product list** (`product_list_screen.dart`): searchable by name, filterable by category, brand, author, publisher, price range (min/max), product type (physical/digital), and status (active/inactive). Per-product actions: edit, delete (with confirmation), view.
- **Most popular products**, **Top selling products**, **Stock out (low-stock) products** — each a dedicated filtered view, also surfaced as widgets on the Home dashboard.
- A dismissible "more products have low stock" banner ("don't show again" option).
**Key capabilities/business rules:** product status (active/inactive) is a vendor-controlled visibility toggle separate from the admin approval status.

### `product_details`
**Purpose:** full read view of a single product, including its admin-review state.
**Screens/Flows:** general information, price information, current stock, SKU, unit, shipping cost, discount, product video, SEO/meta data (with fallback "not found" messaging if empty), and a reviews list for that product. Shows approval status prominently: **new request / approved / denied** (with the admin's denial reason if denied).
**Key capabilities/business rules:** supports rich media preview for digital products — video, audio, PDF, and image preview components exist, plus a "download preview file" action — reflecting the digital-goods (ebook/media) heritage of the template.

### `barcode`
**Purpose:** generate and print/download barcodes for physical products (e.g., for in-store shelf labels or POS scanning).
**Screens/Flows:** single screen — pick a product, shows its code, set a quantity (number of labels), Generate, Reset, Download.

### `clearance_sale`
**Purpose:** let a vendor enroll their products into a store-wide clearance/liquidation sale event.
**Screens/Flows:** clearance sale screen shows "active clearance sale offer" status and the vendor's currently-enrolled product list; a separate search screen lets the vendor pick additional products to add. If the platform hasn't configured clearance sale settings yet, the vendor sees a "please setup the configuration first" message instead (i.e., an admin-level prerequisite).
**Key capabilities/business rules:** this is a platform-level event the vendor opts individual products into — not something the vendor creates independently.

### `restock`
**Purpose:** view customer "notify me when back in stock" requests for out-of-stock products.
**Screens/Flows:** a filterable list of restock requests.

---

## 4. Order Fulfillment

### `order`
**Purpose:** order list and per-order delivery-address management.
**Screens/Flows:**
- **Order list** (`order_screen.dart`): tabbed/filtered by status — all, pending, confirmed, processing, out for delivery, delivered, cancelled, failed, returned.
- **Edit address screen**: contact person name, contact number, city, zip — update the delivery address on an order.
- **Select location screen**: map-based location picker for setting/updating an address.
- A dedicated filter bottom sheet (in `order_details`, shared by the list) additionally filters by: payment status (paid/unpaid), date range (from/to), specific customer, order source (POS-only vs. website-only), "has due amount," and "has return amount."

### `order_details`
**Purpose:** the full single-order workspace — the richest screen cluster in the app.
**Screens/Flows:**
- **Order top section**: order status, an "edit this order" entry point (with a warning that unsaved changes will be lost), special handling note for orders containing only digital products, and an offline-payment confirmation action.
- **Customer contact widget**: customer info card, with graceful "guest customer" display for guest checkouts.
- **Delivery man information widget**: shows/assigns the delivery man handling the order.
- **Order setup bottom sheet**: assign a delivery man; for non-inhouse shipping, instead capture a third-party delivery service name and tracking ID; set a delivery incentive amount. Validates all required fields before allowing "update."
- **Billing summary**: subtotal, discount, coupon discount, extra discount, referral discount, tax, shipping fee, total amount, paid amount, amount due.
- **Change-amount widget**: for cash-on-delivery orders, tracks change prepared for the customer and confirms the delivery man has the correct amount.
- **Payment status / payment info widgets**: payment method, order type (regular vs. POS), order verification code, and the ability to **switch an order's payment method to Cash on Delivery** (with an explicit warning before doing so).
- **Edit log**: an audit trail of who edited the order and when, plus messaging when editing has increased or decreased the order's total.
- **Per-product-item file upload**: vendors can upload a "completed service picture" or proof file per line item (validated for file type and max image size), with download/view of previously uploaded files.
- **Order edit** (separate module, see below) is launched from here.
**Key capabilities/business rules:** this screen is the operational hub — assigning delivery, confirming payment, editing contents, and tracking cash reconciliation all happen here.

### `order_edit`
**Purpose:** modify the products/quantities within an existing (not-yet-completed) order.
**Screens/Flows:** edit product screen — shows the current product list on the order, lets the vendor adjust it, recalculates VAT/tax/other charges and the total automatically, with an explicit warning that "editing the price will be updated to the latest [pricing]." Update Cart / Cancel actions.

---

## 5. Point of Sale (POS)

**Purpose:** a full in-person/counter-sale checkout system for the vendor's physical shop — a capability with no equivalent in the User (buyer) app. Entered via its own `NavBarScreen` shell (POS / My Order / Products / Menu tabs).

**Screens/Flows:**
- **POS product screen**: browse/search the catalog, filter by category (bottom-sheet filter), tap to add to cart; variant products open a **variation selection dialog** (color/attribute picker) before adding.
- **Barcode scanning**: items can be added by scanning a barcode directly ("scan item or add from item list").
- **POS screen (cart/checkout)**:
  - Cart list with per-item quantity, price, and an editable per-item **discount** (amount or percentage).
  - **Coupon apply widget**: enter and apply a coupon code.
  - **Extra discount and coupon dialog**: an additional order-level discount on top of any coupon, with validation that the discount doesn't exceed the order total.
  - Live bill summary: subtotal, tax (VAT, shown as tax-inclusive where applicable), discount, coupon discount, total.
  - **Customer step**: search existing customers by name/phone, or **add a new customer** on the spot (first name, last name, phone, email, address, city, country, zip — with per-field validation).
  - **Payment**: select payment method; if paying from the customer's wallet, validates sufficient wallet balance; captures paid amount (validated to not be zero or less than the order total) and computes **change amount** due back to the customer.
  - **Confirm purchase dialog** before finalizing.
  - Stock rules enforced: out-of-stock items blocked, minimum order quantity enforced per product.
- **Hold orders**: a cart-in-progress can be "held" (parked) with a hold ID/name and a note, browsable in a separate hold-orders list, and resumed later ("resume" action) — supports interrupting a sale to serve another customer.
- **Invoice**: after purchase, an invoice/receipt screen is generated; can be **printed via a connected Bluetooth thermal printer** (device pairing/connection flow — "click to connect," "paired Bluetooth," requires Bluetooth + location permission) or downloaded/shared digitally. A "thank you" confirmation is shown.
**Key capabilities/business rules:** POS orders with digital products are handled specially (flagged distinctly from physical POS sales); wallet-based payment is fully validated against balance; the whole flow works without a customer profile if none is created/selected (implied by an optional customer step design, though a customer entry is generally expected for receipts).
**Dependencies:** Bluetooth (thermal printer), device camera/scanner (barcode), local cart state persisted enough to survive holding/resuming.

---

## 6. Auction (Seller Side)

**Purpose:** create, manage, and monitor livestock/product auctions from the vendor side. This is a first-class, config-gated feature (`isAuctionFeatureEnabled` platform-wide AND `activeAuctionForVendor`/`showAuctionMenuForVendor` per-vendor) — not an appendix. The buyer/bidding-side experience is documented separately in the User app blueprint; this section covers only what the vendor controls.

**Screens/Flows — Auction Menu** (the entry hub, mirrors the main app Menu pattern): Create Auction (only shown if the vendor is allowed to create), All Auctions, Auction Request List (pending admin approval), Auction Sales Report, Transaction with Admin, Auction Tax Report.

- **Create Auction** (`AddAuctionProductTabView`) — a 3-tab wizard mirroring the standard product wizard:
  - **General Info**: product name, description, images — closely mirrors `addProduct`'s general tab, and supports the same AI-assisted generation (a separate `AuctionAiController`, distinct from the standard product AI controller) including **image-driven auto-fill**: uploading a photo can auto-generate not just the description but also the following tab's auction terms.
  - **Auction Info**: starting price, **minimum increment amount** (how much each new bid must exceed the last by), **maximum decrement amount** (suggests support for a descending/Dutch-style price mechanic in addition to standard ascending bidding), auction start time and end time (date/time pickers), applicable VAT/tax selection (multi-select from configured tax types), tags. Supports **"relaunch"** mode — recreating/reposting an auction that didn't sell, pre-filled from the original but with fresh start/end times.
  - **SEO**: meta title/description/image, same pattern as standard products.
- **Auction List**: the vendor's own auctions, with statuses spanning the full lifecycle: **live → completed/cancelled → delivered/on the way/ready to claim/purchase complete**. Actions: cancel a live auction, delete an auction (with confirmation), re-create (relaunch) a completed one.
- **Auction Request List**: auctions pending admin approval, separately trackable as **pending** or **rejected**.
- **Bidding Details / Auction Insights**: for a given auction — total bids, total participants, total views, highest bid, highest jump (largest single bid increase), average bid increase. Also surfaces **payment info** (admin commission owed) and a **delete** action.
- **Auction Sales Report**: per-auction rows showing gross sales before commission, commission paid, gross sales after commission, completion date, and status across the full lifecycle (approved/live/completed/cancelled/delivered/on the way).
- **Transaction with Admin / Auction Digital Payment**: the vendor pays the platform's commission on completed auction sales through a digital payment flow ("commission paid successfully").
- **Auction Tax Report**: totals — total auctions, total auction amount, total VAT amount collected across auctions.
- **Auction Transaction List**: searchable by auction number, filterable by this month / this year / custom date range / clear all.
- **Edit Auction Address**: delivery address for a won/physical auction item — contact person name/number, email, country, city, zip.
**Key capabilities/business rules:** auctions require admin approval before going live (pending/rejected states), just like standard products require approval. The vendor pays commission separately from standard order commission, tracked in its own wallet ledger (see Wallet below) and its own tax report.
**Dependencies:** platform auction feature flag; per-vendor auction permission flag; AI service (optional, for auto-fill); tax/VAT configuration.

---

## 7. Finance & Wallet

### `wallet`
**Purpose:** the vendor's financial summary and withdrawal history — split into two entirely separate ledgers.
**Screens/Flows:**
- **Main shop wallet**: collected cash, commission given (to platform), delivery charge earned, total collected tax, withdrawn amount, pending withdrawn amount, and a withdraw-history list ("view all").
- **Auction wallet** (separate section/tab): auction total earning, auction pending commission, auction total commission given, auction total shipping, auction total VAT, auction withdrawable balance, auction total pending amount, auction pending withdraw.
**Key capabilities/business rules:** auction revenue is tracked completely separately from standard order revenue — a rebuild needs two independent balance/ledger models, not one.

### `transaction`
**Purpose:** detailed transaction history and withdrawal-request management.
**Screens/Flows:** transaction list (filterable by month/year), transaction detail view (transaction ID), and the ability to **delete/cancel a pending withdraw request** (with confirmation), plus a shortcut to edit payment info.

### `bank_info`
**Purpose:** the bank account details used for payouts/withdrawals.
**Screens/Flows:** view current bank info (with a prompt to fill it in if empty); edit screen collects bank name, branch name, account number, account holder name.

### `vat_management`
**Purpose:** tax/VAT reporting hub.
**Screens/Flows:** a small hub linking to **VAT Report** (order list with total orders, total order amount, total VAT amount) and **Auction Sales Report**. Also references an **Expense Report** — **confirmed unimplemented**: the screen exists in navigation but its body is literally a placeholder reading "Need Design." Document this as a known gap, not a feature to silently drop or silently reimplement without spec.

### `coupon`
**Purpose:** vendor-created discount coupons for their own products.
**Screens/Flows:** coupon list; add/edit coupon screen collecting: title, code (with a "generate" random-code button), discount amount, discount type, maximum discount cap, minimum purchase amount (validated to be greater than the discount amount, to prevent a coupon that's always fully-discounting), expiry date, and a per-customer usage limit.

---

## 8. Staff & Delivery Management

### `delivery_man`
**Purpose:** lets a vendor recruit, manage, and pay their own dedicated delivery riders — a self-contained mini fleet-management system, distinct from relying on the platform's shared delivery pool. (Home dashboard's "Top Delivery Man" widget is hidden when the shop uses `inhouse_shipping` — i.e., this whole module is most relevant when the vendor runs their own delivery staff.)
**Screens/Flows:**
- **Delivery Man List / Setup / Add New**: create a delivery man profile — first name, last name, email, phone (validated), password + confirm password (validated, with a password-strength check), profile image (required), identity number and identity image (ID document — required, for verification/accountability).
- **Delivery Man Details**: full profile view plus **order history** for that specific rider, and their **earning statement**.
- **Top Delivery Man**: a leaderboard/overview screen.
- **Delivery Man Overview**: aggregate stats.
- **Collect Cash from Delivery Man**: reconciliation flow for cash-on-delivery collections — the amount received back from the rider cannot exceed the cash they're recorded as currently holding ("receive amount can't be more than cash in hand").
- **Withdraw flow** (own sub-module): delivery man withdrawal requests, with current balance / withdrawable balance / pending withdraw / total withdrawn tracked per rider; the vendor **approves or denies** each request (with a confirmation dialog either way); a withdraw list and per-request details screen show bank info (holder, account number, bank name, branch name) for the payout.
**Key capabilities/business rules:** identity verification (ID number + photo) is mandatory when onboarding a delivery man — a compliance/trust feature worth preserving deliberately, not incidentally.

---

## 9. Shop & Business Settings

### `shop`
**Purpose:** the vendor's public shop profile and operational settings.
**Screens/Flows:**
- **Shop screen**: overview, including the shop's registration/start date.
- **Shop update screen**: shop name, address, contact number, shop logo, shop cover image, offer banner, secondary/store banner (theme-dependent), each with an "image size" hint and reset option.
- **Vacation mode setup**: turn the shop temporarily closed — choose a custom date range (start/end, validated so end isn't before start) or "until I change" (indefinite), with a required note explaining the closure, shown to customers. A "you have scheduled shop [closure]" state is distinct from "your shop is currently [closed]" (i.e., scheduled-future vs. active-now are both represented).
- **Payment info / Add payment info screens**: vendor-managed **custom offline payment methods** (beyond the platform's built-in gateways) — method name, payment status, can be marked as default, enabled/disabled (with a warning that disabling affects checkout availability), edited, or deleted. New methods may require admin verification before going live ("please verify your payment method").
- **Other setup screen**: free-delivery-over-amount threshold, minimum order amount, re-order/restock alert level, business TIN number + expiry date + certificate upload (max file size enforced).

### `settings`
**Purpose:** a settings hub plus order-wise (flat-rate) shipping method management.
**Screens/Flows:** language chooser shortcut, shipping-setting entry point; **order-wise shipping list** (add new, view details, per-row actions) and **add/edit shipping method** screen (title, cost, duration — both create and update supported, with distinct success messages).

### `shipping`
**Purpose:** the two shipping-configuration modes available to a vendor.
**Screens/Flows:** **Shipping main screen** hosts both **order-wise shipping** (flat per-order methods, managed under `settings` above) and **category-wise shipping** (assign a specific shipping method per product category, with its own save/update flow).

---

## 10. Customer Interaction

### `chat`
**Purpose:** direct messaging between the vendor and customers (and likely delivery staff/admin, per the User app's parallel chat feature).
**Screens/Flows:** **Inbox** (conversation list), **Chat screen** (message thread) supporting multi-image attachments in a single message (with a max-image-count limit, a per-file size limit, and a total-attachment-size limit, all validated client-side before sending), and a **media viewer** for viewing sent images full-screen.

### `review`
**Purpose:** view and respond to customer product reviews.
**Screens/Flows:** **Product Review screen** — searchable by product name, listing reviews. **Review Full View** — a single review in detail. **Review Reply**: the vendor can write (and later update) a public reply to a review, tied to the order ID it came from.

### `refund`
**Purpose:** manage customer refund requests.
**Screens/Flows:** refund list filterable by status (all/pending/approved/refunded/rejected) and by date range (today/this week/this month/custom/all time); a refund details screen for a single request.

---

## 11. Account & Profile

### `profile`
**Purpose:** the vendor's own personal account info (distinct from shop info, which lives under `shop`).
**Screens/Flows:** **Profile view** (shows app version too) and **edit profile** — first name, last name, phone, and an optional password change (current/new with confirmation, validated for length and match, only submitted if something actually changed).

---

## 12. Support & Misc

### `emergency_contract`
**Purpose:** despite the unusual module name (not a typo for "contact" in the UI — it's a maintained list of emergency contacts), this is a searchable directory of emergency contacts the vendor keeps on file, with add-new (via a floating action button and dialog) and search capability. Likely intended for shop-safety or operational-emergency numbers (not a legal "contract" document).
**Screens/Flows:** single searchable list screen with a "+" FAB opening an add-contact dialog.

### `more`
**Purpose:** a generic HTML content viewer, reused throughout the app for legal/informational pages.
**Screens/Flows:** `HtmlViewScreen` renders a `BusinessPageModel` (slug-based) — used for Terms & Conditions, About Us, Privacy Policy, Refund/Return/Cancellation Policy, all fetched from the backend as HTML content rather than hardcoded.

### `language`
**Purpose:** in-app language switching.
**Screens/Flows:** a single language-selection screen. Bundled languages: **Arabic, Bengali, English, Spanish, Hindi** (`ar/bn/en/es/hi` — same 5-language set as the User app; **no Swahili** bundled, worth flagging for a Kenyan storefront).

### `notification`
**Purpose:** in-app notification center, mirroring push notifications.
**Screens/Flows:** tabbed **General** vs. **Auction** notifications (auction tab only relevant/counted when the auction feature is enabled), each item has a "visit" action that deep-links into the relevant screen. Deep-link types confirmed in the push-notification handler: `chatting`, `order` (generic order-id-based), `wallet_withdraw`, `product_request_approved_message` (product approval outcome), `refund`, and `auction*` (auction-specific types, routed by auction ID). A "Theme" push type also exists (likely a remote theme/config refresh signal, not user-facing content).

---

## 13. Platform / Infrastructure

These aren't `features/` modules but are real product behavior a rebuild must account for:

- **Localization**: 5 bundled languages (ar, bn, en, es, hi — see `language` above), driven by `lib/localization/` (`app_localization.dart`, `localization_controller.dart`) reading JSON files from `assets/language/`.
- **Theming**: light and dark theme support (`lib/theme/light_theme.dart`, `dark_theme.dart`, `theme_controller.dart`) — user-toggleable, referenced throughout the UI (e.g., menu bottom-sheet background adapts).
- **Push notifications**: Firebase Cloud Messaging integration (`lib/notification/`) with a typed `NotificationBody` payload model and deep-link routing (types enumerated under `notification` above), plus local notification display (`flutter_local_notifications`) for foreground messages.
- **No offline/local data cache**: unlike the User app (which uses a local `drift` database for offline browsing), the Vendor app's data layer (`lib/data/datasource/remote/`) is remote-only — every screen fetches live from the API. A rebuild should decide deliberately whether to add offline support, since the current app doesn't have it as a baseline to match.
- **Shared design system**: `lib/common/basewidgets/` (~45 files) — reusable buttons, text fields (including a dedicated phone-number-with-country-code field), dialogs (confirmation, custom animated), snackbars, app bars, bottom sheets, search fields, and list-delegate helpers used consistently across all 36 feature modules above. A rebuild should budget for an equivalent shared component library rather than one-off screen styling.
- **Connectivity handling**: `NetworkInfo.checkConnectivity()` is invoked at app-shell and screen level (dashboard, home) to detect and presumably react to connectivity loss.
- **Country/phone handling**: `country_code_picker` used consistently anywhere a phone number is collected (registration, forgot password, delivery man setup, POS new-customer, auction address) — default country code driven by server config (`configModel.countryCode`).

---

## 14. Completeness checklist

All 36 `lib/features/` modules, confirmed covered above:

- [x] addProduct
- [x] ai
- [x] auction
- [x] auth
- [x] bank_info
- [x] barcode
- [x] chat
- [x] clearance_sale
- [x] coupon
- [x] dashboard
- [x] delivery_man
- [x] emergency_contract
- [x] home
- [x] language
- [x] maintenance
- [x] menu
- [x] more
- [x] notification
- [x] order
- [x] order_details
- [x] order_edit
- [x] pos
- [x] product
- [x] product_details
- [x] profile
- [x] refund
- [x] restock
- [x] review
- [x] settings
- [x] shipping
- [x] shop
- [x] splash
- [x] transaction
- [x] update
- [x] vat_management (including the confirmed-unimplemented expense report sub-screen)
- [x] wallet

Plus infrastructure: localization, theming, push notifications, shared widget library, connectivity handling, country/phone handling — all covered in §13.
