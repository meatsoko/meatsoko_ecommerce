# CLAUDE.md

## Project overview

Laravel-based web storefront + admin panel for **MeatSoko**, a Kenyan meat/livestock
e-commerce marketplace, built on the licensed **6valley** multi-vendor commerce
template (6amTech) — this is a customization of a purchased template, not built
from scratch. Multi-vendor: customers, vendors (sellers), and admin all served from
this one Laravel app, plus `nwidart/laravel-modules` add-ons (see Modules below).

Two companion Flutter mobile apps (customer + vendor) exist and talk to this
backend's API (`routes/rest_api/v{1,2,3}`), but as of 2026-08-30 they live in a
**separate repo** (`github.com/meatsoko/mobile_app.git`, previously `User app/` and
`Vendor app/` in this repo) so mobile and web/backend can be versioned and deployed
independently. See that repo's own `CLAUDE.md` for mobile-specific context.

**Branch status (check before assuming what's "current"):**
- `app_review` (this branch) — MeatSoko brand reskin of the storefront (home page,
  navbar, categories, login/register) plus various feature work. Currently the
  active working branch for storefront/UX changes.
- `main` — has diverged: includes M-Pesa gateway refactoring and some fixes not on
  `app_review`, but **not** the storefront reskin.
- `origin/upgrade/v16.5-features` — built on `main`, not `app_review`. Adds a V16.5
  courier/delivery-partner add-on (9 providers), an AI shopping assistant +
  personalized homepage, 6amERP integration, and an Equity Bank payment gateway.
  **Not merged anywhere yet** — `app_review` and this branch will need reconciling
  before both the reskin and the V16.5 features can ship together.

## Project Rules
@.claude/rules/translate.md
@.claude/rules/response-style.md
@.claude/rules/coding-standards.md
@.claude/rules/auction-ui.md

## Commands

### Artisan
- `php artisan serve` — dev server
- `php artisan migrate` — apply pending migrations (see Database note below)
- `php artisan optimize:clear` — clear all caches
- `php artisan generate:entity {name}` — scaffold model + repo interface + impl
- `php artisan file:permission` — fix storage permissions after deployment

### Frontend (Laravel Mix 5)
- `npm run dev` / `npm run watch` / `npm run prod`

## Database
**Critical:** Never run `php artisan migrate` on an empty database. Import `installation/backup/database.sql` first, then migrate.

## Architecture

**Flow:** Controller → Service → Repository → Model. Controllers are thin; logic lives in `app/Services/`. Repos in `app/Contracts/Repositories/`. Helpers in `app/Utils/`.

**Routes** (non-standard, loaded by `app/Providers/RouteServiceProvider.php`):
- Admin: `routes/admin/routes.php`
- Vendor: `routes/vendor/routes.php`
- Web: `routes/web/routes.php`
- API v1/v2: `routes/rest_api/v{1,2}/api.php`
- API v3 seller: `routes/rest_api/v3/seller.php`
- Each `Modules/` dir has its own RouteServiceProvider.

**Modules** (`nwidart/laravel-modules`): `Modules/AI`, `Modules/Auction`, `Modules/Blog`, `Modules/TaxModule` — each is a self-contained mini-app.

**Bootstrap:** `AppServiceProvider` loads themes, settings, payment configs, and add-on states from DB at boot. Many behaviors are DB-driven, not code-driven.

**AI Module:** `Modules/AI/AIProviders/AIProviderManager.php` selects active provider (OpenAI/Claude) from DB config.

**Frontend:** Vue 2 + Bootstrap 4 + Laravel Mix 5 — intentionally legacy, be conservative.

