# app_review — What This Branch Includes

**Base:** diverges from `main` at `10ee5fa` (fix: match index() signature to ControllerInterface across admin controllers).
**Scope of this document:** everything unique to `app_review` vs `main` — five commits, almost entirely a MeatSoko brand reskin of the customer-facing storefront, plus one unrelated Flutter mobile-app bugfix pass that shipped in the same commit as the design source files.

No database migrations, no `composer.json`/`package.json` dependency changes, no backend logic changes. This branch is safe to review purely as a front-end/visual diff.

---

## 1. Storefront reskin — MeatSoko brand

Driven by `xdocs/ui_guide` (a UX brief recommending a stronger homepage hierarchy, a meat-first "Shop Meat" section, benefit/trust cards, and a clearer shopping journey) and cross-checked against `xdocs/review.md` (a UX audit of the live site). The mockups the reskin was built from live in `meatsoko-mockup/` (17 static HTML pages — home, category, product, cart, checkout, auth, account, and policy pages — a Vercel-deployable design reference, not shipped to the Laravel app).

**New design system:** `public/assets/front-end/css/meatsoko-revamp.css` — loaded last in `layouts/front-end/app.blade.php` so it wins the cascade without touching existing markup/JS hooks. Defines the brand's color tokens (ink/rust/olive/cream/stone palette), typography (Fraunces serif for headings, Work Sans for body), and a library of reusable `.ms-*` components (section headers with eyebrow labels, trust cards, category grid tiles, auth panels, breadcrumbs, checkout steps) used across the pages below.

**Home page** (`home.blade.php`):
- New trust-card strip (Quality Assured / Fresh & Carefully Handled / Reliable Delivery / Secure Payments).
- New "Categories" section styled as a branded image-tile grid (`.ms-cat-grid`), replacing the old plain icon-list partial — pulls real category data and icons, capped at 6 tiles.
- New "Why shop with MeatSoko?" and "How It Works" sections (home page only — not duplicated elsewhere).
- Removed a redundant per-category product-carousel block that repeated the same information as the new categories grid.

**Navigation** (`_header.blade.php`):
- Fixed the active-tab logic: several nav items (Publication House, All Vendors, Flash/Featured/Discounted/Clearance Deal) incorrectly lit up whenever the visitor was on the homepage, and never lit up on their own page. Replaced with correct `route()`-based checks; added active-state to Brand and Categories, which previously had none.
- Fixed page order: Home now renders before the Categories mega-menu (was previously reversed).
- Fixed a legacy CSS rule (`.mega-nav { background: white }` in the base theme) that was punching a white box into the dark navbar behind the Categories toggle.
- Added a rust-colored underline as the active-tab indicator, consistent with the rest of the design system.

**Footer** (`_footer.blade.php` and the Auction module's `_footer.blade.php`):
- Replaced the App Store/Google Play download badges with a "Coming Soon" pill — the apps aren't live yet, so real store links no longer render.

**Login / Register** (`login.blade.php`, `register.blade.php`):
- Rebuilt as a two-panel "swap" layout: a dark benefits panel (why log in / why register) alongside the form, with the panel switching sides between the two pages and a tab bar for cross-navigation.
- All existing form logic is untouched — every login mode (manual, OTP, social, combinations), captcha, reCAPTCHA, and validation still uses the original partials and JS hooks; only the surrounding shell changed.

**Rolled out to the rest of the storefront** (breadcrumbs + CSS overrides only, no JS/markup changes to filters, cart AJAX, or forms): cart, checkout (shipping/payment), track order, categories listing, product details, product listing, business/about pages, contact us, FAQ.

## 2. Known gaps vs. the design brief

- `xdocs/ui_guide` recommends splitting the category set into a meat-first "Shop Meat" group and a separate "Farm & Agriculture" group. The live category taxonomy (9 categories: Choma Zone, Dairy, Meat, Health, Poultry, Equipments, Services, Feeds, Livestock) doesn't carry that grouping in the schema, so the current home page shows one flat grid instead — not yet implemented.
- The home page category grid is capped at 6 tiles; production actually has 9 categories, so 3 won't appear in the teaser without a follow-up change.
- `meatsoko-revamp.css` isn't cache-busted (no version query string), so returning visitors may see the old stylesheet until their browser cache expires.

## 3. Mobile apps — unrelated Flutter fixes

Bundled into the same commit as the design source files (`4c03a99`), but functionally unrelated to the reskin:
- **User app:** stubbed ~30 missing auction-module files that were causing ~330 compile errors; fixed 7 runtime crash bugs (non-JSON API error bodies, unhandled timeout case, empty geocoding results, unguarded `double.parse` in the wallet flow, and related issues).
- **Vendor app:** matching interface/repository fixes for the auction and notification modules, plus a price-converter fix.

## 4. Docs added

- `xdocs/ui_guide` — the UX brief this reskin was built against.
- `xdocs/review.md` — a UX audit of the live storefront, used as supplementary input.
- `meatsoko-mockup/` — the static HTML design reference (Vercel-deployable) the reskin's markup and CSS were ported from.

---

## Commits in this branch

| Commit | Summary |
|---|---|
| `5603da3` | auditing images match — confirmed no hardcoded/broken image references in the reskin |
| `6dfde57` | ui revamp — navbar fixes, footer Coming Soon badge, home categories grid, login/register swap layout |
| `f9dcd4b` | roll out MeatSoko mockup design to remaining storefront pages |
| `ad73ec7` | reskin storefront home page with MeatSoko brand mockup design |
| `4c03a99` | fix Flutter build errors in User/Vendor apps; add web UX mockup + design docs |
