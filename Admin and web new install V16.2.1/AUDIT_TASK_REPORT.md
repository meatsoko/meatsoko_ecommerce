# MeatSoko Ecommerce V16.2.1 — Audit Task Report

**Project:** MeatSoko Ecommerce  
**Version:** V16.2.1  
**Audit Date:** 2026-06-25  
**Auditor:** Claude Code (AI-assisted review)  
**Status:** Closed — fixes applied 2026-07-09 (see per-task status below)  

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 4     |
| High     | 6     |
| Medium   | 7     |
| Low      | 3     |
| **Total**| **20**|

---

## Task List

---

### TASK-001 — Wrap refund processing in a database transaction

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-001 |
| **Status**  | Fixed — wrapped in `DB::transaction()` |
| **Severity**| Critical |
| **Category**| Data Integrity |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 133–157 |

**Problem:**  
`updateRefundStatus()` performs multiple sequential database writes — wallet balance update, refund transaction record creation, order/refund status update, loyalty point deduction — with no wrapping `DB::transaction()`. If an exception or server crash occurs between any two steps, the wallet is already debited but the refund is never completed. This results in real money loss with no correctable audit trail.

**Fix:**  
Wrap lines 133–157 in `DB::transaction(function () use (...) { ... })`. All writes must succeed or all must roll back.

---

### TASK-002 — Guard against negative wallet balance on refund deduction

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-002 |
| **Status**  | Fixed — balance guard added before deduction |
| **Severity**| Critical |
| **Category**| Data Integrity / Business Logic |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 136, 139 |

**Problem:**  
The code directly subtracts `$refund['amount']` from the admin or vendor wallet balance without first checking whether the balance is sufficient. If the balance is lower than the refund amount (e.g. partial refunds were already issued), the stored value becomes negative.

```php
// Line 136
'inhouse_earning' => $adminWallet['inhouse_earning'] - $refund['amount']

// Line 139
'total_earning' => $sellerWallet['total_earning'] - $refund['amount']
```

**Fix:**  
Before each deduction, assert the wallet balance is sufficient and return an error response if not:
```php
if ($adminWallet['inhouse_earning'] < $refund['amount']) {
    return response()->json(['error' => translate('Insufficient wallet balance to process refund.')]);
}
```

---

### TASK-003 — Fix race condition allowing duplicate refund approvals

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-003 |
| **Status**  | Fixed — `lockForUpdate()` added inside the transaction |
| **Severity**| Critical |
| **Category**| Race Condition |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 111–114 |

**Problem:**  
The current guard checks refund status before writing, but does not lock the row. Two simultaneous admin requests can both pass the `if ($refund['status'] == 'refunded')` check before either commits, resulting in the refund being processed twice and the wallet debited twice.

```php
$refund = $this->refundRequestRepo->getFirstWhere(params: ['id' => $request['id']]);
if ($refund['status'] == 'refunded') { // no row lock here
```

**Fix:**  
Use pessimistic locking inside the `DB::transaction()` from TASK-001:
```php
$refund = RefundRequest::lockForUpdate()->findOrFail($request['id']);
```

---

### TASK-004 — Re-verify payment amount server-side before gateway redirect

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-004 |
| **Status**  | Fixed — cart total snapshotted at redirect time and re-verified against the live cart before order creation; order is not created on mismatch |
| **Severity**| Critical |
| **Category**| Payment Security |
| **File**    | `app/Http/Controllers/Customer/PaymentController.php` |
| **Lines**   | 43–80 |

**Problem:**  
The controller only validates `payment_method` and `payment_platform`. The cart total is computed and forwarded to the payment gateway, but the amount is never locked to a signed server-side value. A user who modifies their cart between the checkout page load and the gateway callback can underpay.

**Fix:**  
Before redirecting to any payment gateway, compute the expected total, store it in a signed/encrypted session or database token (keyed to the cart state), and verify the callback amount matches the stored token. Reject any callback where amounts differ.

---

### TASK-005 — Add granular permission checks on sensitive admin routes

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-005 |
| **Status**  | Fixed (defense-in-depth scope) — explicit `module_permission_check()` calls added inside the sensitive controller methods; a full per-action permission schema rework was scoped out by the client as a separate future initiative |
| **Severity**| High |
| **Category**| Authorization |
| **File**    | `routes/admin/routes.php` |
| **Lines**   | All admin route groups |

**Problem:**  
All admin routes share a single `['admin', 'actch:admin_panel']` middleware group. No route-level or controller-level `Gate` / `authorize()` checks exist on sensitive operations: wallet top-ups, refund status changes, order payment-status overrides, delivery man fund collection. Any admin account — regardless of role — can perform all of these actions.

**Fix:**  
Leverage the existing `AdminRole` model. Add `authorize('manage-refunds')`, `authorize('manage-wallets')`, and similar Gate checks at the start of each sensitive controller method. Alternatively, register named middleware per module and apply to route groups.

---

### TASK-006 — Enforce cart item ownership before update or delete

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-006 |
| **Status**  | Fixed — `removeFromCart()` and `CartManager::update_cart_qty()` were already scoped; `updateQuantity_guest()`'s unscoped `Cart::find()` now scopes by customer/guest id |
| **Severity**| High |
| **Category**| Authorization |
| **File**    | `app/Http/Controllers/Web/CartController.php` |
| **Lines**   | removeFromCart, updateQuantity methods |

**Problem:**  
Cart remove and quantity-update actions do not verify that the authenticated user owns the cart item. An authenticated user who knows another user's cart item ID can delete or modify it.

**Fix:**  
Scope all cart queries to the authenticated user:
```php
Cart::where('id', $id)
    ->where('customer_id', auth()->id())
    ->firstOrFail();
```

---

### TASK-007 — Verify refund request belongs to authenticated customer

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-007 |
| **Status**  | Fixed — `customer` middleware added to the route (it was missing entirely, not just the ownership check), plus `abort_if` ownership guard added in `refund_request()` and `store_refund()` |
| **Severity**| High |
| **Category**| Authorization |
| **File**    | `routes/web/routes.php` / refund request controller |
| **Lines**   | `/refund-request/{id}` route handler |

**Problem:**  
The `/refund-request/{id}` route accepts an order ID but the handling controller does not verify the order belongs to the currently authenticated customer. An authenticated customer can initiate a refund on any order by guessing a numeric ID.

**Fix:**  
In the refund request controller, add:
```php
abort_if($order->customer_id !== auth('customer')->id(), 403);
```

---

### TASK-008 — Add ownership check on order edit due-payment endpoint

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-008 |
| **Status**  | Fixed — ownership guard added covering both authenticated-customer and guest orders |
| **Severity**| High |
| **Category**| Authorization |
| **File**    | `app/Http/Controllers/Customer/PaymentController.php` |
| **Lines**   | ~494 (`customerOrderEditPayDueAmount`) |

**Problem:**  
`customerOrderEditPayDueAmount()` processes a due payment for an edited order but does not verify that `$order->customer_id` matches the authenticated customer. Another authenticated customer could pay (or trigger payment flows for) someone else's order.

**Fix:**  
Add before processing:
```php
abort_if($order->customer_id !== auth('customer')->id(), 403);
```

---

### TASK-009 — Validate cart quantity input (min, max, integer)

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-009 |
| **Status**  | Fixed — quantity validation added to `getVariantPrice()`, `addToCart()`, and `update_variation()` |
| **Severity**| High |
| **Category**| Input Validation |
| **File**    | `app/Http/Controllers/Web/CartController.php` |
| **Lines**   | 57 (`$requestQuantity = $request['quantity']`) |

**Problem:**  
The `quantity` parameter from the request is used directly with no validation. A user can submit `quantity = -5` or `quantity = 0`, which corrupts cart totals and can produce negative pricing or bypass minimum order quantity rules.

**Fix:**  
Add validation at the start of any method that receives a quantity:
```php
$request->validate([
    'quantity' => 'required|integer|min:1|max:10000',
]);
```

---

### TASK-010 — Enforce stock limit for simple (non-variant) products

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-010 |
| **Status**  | Fixed — the gap was actually in `CartController::addToCartPhysicalProduct()`'s non-variant branch (used by `update_variation()`); `CartManager::add_to_cart()` already enforced stock for both cases |
| **Severity**| High |
| **Category**| Business Logic |
| **File**    | `app/Http/Controllers/Web/CartController.php` |
| **Lines**   | ~102 |

**Problem:**  
The quantity-vs-stock check only runs for products that have variations. Products with no variants skip this check entirely, allowing customers to add quantities that exceed available stock.

**Fix:**  
Extract the stock check into a shared method and call it for all product types, not just those with variations.

---

### TASK-011 — Handle null `orderDetails` gracefully in refund detail view

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-011 |
| **Status**  | Fixed — `getDetailsView()` already guarded; null-check added in `updateRefundStatus()` before any wallet mutation |
| **Severity**| Medium |
| **Category**| Bug |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 85–88 |

**Problem:**  
When `$refund->orderDetails` is `null`, the arithmetic on line 85 evaluates to `0` silently:
```php
$subtotal = ($refund?->orderDetails?->price * $refund?->orderDetails?->qty) - ...;
```
The view then displays zero refund amounts with no indication of a data problem.

**Fix:**  
Add an explicit null guard and return an error or warning when `orderDetails` is missing:
```php
if (!$refund->orderDetails) {
    ToastMagic::error(translate('Order details not found for this refund.'));
    return back();
}
```

---

### TASK-012 — Enforce valid order status transitions

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-012 |
| **Status**  | Fixed — status changes are rejected once an order reaches a terminal status (delivered/canceled/returned/failed) |
| **Severity**| Medium |
| **Category**| Business Logic |
| **File**    | `app/Http/Controllers/Admin/Order/OrderController.php` |
| **Lines**   | ~674 |

**Problem:**  
There is no state-machine validation on order status changes. An admin can move an order from `delivered` back to `pending`, or from `canceled` back to `processing`. This breaks financial reconciliation and reporting accuracy.

**Fix:**  
Define and enforce a transition map:
```php
$validTransitions = [
    'pending'    => ['confirmed', 'canceled'],
    'confirmed'  => ['processing', 'canceled'],
    'processing' => ['out_for_delivery', 'canceled'],
    'out_for_delivery' => ['delivered', 'failed'],
    'delivered'  => [],
    'canceled'   => [],
    'failed'     => [],
];
```
Reject any status update where `$newStatus` is not in `$validTransitions[$order->order_status]`.

---

### TASK-013 — Confirm decimal precision migration has run on all environments

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-013 |
| **Status**  | Not a code fix — added to deployment checklist; verify via `php artisan migrate:status` on each environment |
| **Severity**| Medium |
| **Category**| Data Integrity |
| **File**    | `database/migrations/2026_05_07_000001_update_all_decimal_columns_to_40_20.php` |
| **Lines**   | Whole migration |

**Problem:**  
This migration updates all decimal columns across the schema to `(40,20)` precision. If any staging, UAT, or production environment has not run this migration, price and wallet values may have been silently truncated. Inconsistent precision between environments can also cause arithmetic errors in reporting.

**Fix:**  
Run `php artisan migrate:status` on all environments and verify this migration shows as `Ran`. Document the requirement in the deployment checklist.

---

### TASK-014 — Validate date inputs on refund export endpoint

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-014 |
| **Status**  | Fixed — date validation added to `exportList()` and `index()` |
| **Severity**| Medium |
| **Category**| Input Validation |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 164–179 (`exportList`) |

**Problem:**  
`from_date` and `to_date` from the request are passed directly to the repository query with no format validation or sanitization. A malformed date string reaches the database query without being caught.

**Fix:**  
Add validation before the repository call:
```php
$request->validate([
    'from_date' => 'nullable|date_format:Y-m-d',
    'to_date'   => 'nullable|date_format:Y-m-d|after_or_equal:from_date',
]);
```

---

### TASK-015 — Remove duplicate `Product::find()` query in `getVariantPrice`

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-015 |
| **Status**  | Fixed — redundant `Product::find()` replaced with the already-fetched `$product` |
| **Severity**| Medium |
| **Category**| Performance |
| **File**    | `app/Http/Controllers/Web/CartController.php` |
| **Lines**   | 67 |

**Problem:**  
`Product::find($request->id)` is called on line 67 to decode `choice_options`, but the same product was already fetched nine lines earlier on line 58 as `$product`. This is a redundant database query on every price-check request (which fires on every product page interaction).

**Fix:**  
Replace:
```php
foreach (json_decode(Product::find($request->id)->choice_options) as $key => $choice) {
```
With:
```php
foreach (json_decode($product->choice_options) as $key => $choice) {
```

---

### TASK-016 — Verify `getWebConfig()` uses in-memory caching

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-016 |
| **Status**  | Already resolved — `getWebConfig()` (`app/Utils/settings.php`) already wraps its DB lookup in `Cache::remember()`; no code change needed |
| **Severity**| Medium |
| **Category**| Performance |
| **File**    | `app/Http/Controllers/Admin/Order/RefundController.php` |
| **Lines**   | 55–56, 90–91 |

**Problem:**  
`getWebConfig('wallet_status')` and `getWebConfig('wallet_add_refund')` are called in both `index()` and `getDetailsView()`. If the helper performs a database query on each call without an in-request or in-memory cache, a refund list page with 50 rows triggers 100+ setting lookups per request.

**Fix:**  
Inspect the `getWebConfig()` helper. If it does not use `Cache::remember()`, add it. At minimum, use a static variable inside the helper to cache results for the lifetime of the request.

---

### TASK-017 — Remove stray `FontLib` import from `PaymentController`

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-017 |
| **Status**  | Fixed — stray import removed |
| **Severity**| Low |
| **Category**| Code Quality |
| **File**    | `app/Http/Controllers/Customer/PaymentController.php` |
| **Lines**   | 27 |

**Problem:**  
```php
use FontLib\Table\Type\name;
```
This import from a font-parsing library has no purpose in a payment controller. It is a stray import that may cause confusion and increases autoload noise.

**Fix:**  
Delete line 27.

---

### TASK-018 — Add soft deletes to the `Order` model

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-018 |
| **Status**  | Fixed — `SoftDeletes` trait added with migration; no raw `Order::delete()`/`destroy()` call sites found in the codebase |
| **Severity**| Low |
| **Category**| Data Integrity / Audit |
| **File**    | `app/Models/Order.php` |
| **Lines**   | Model class definition |

**Problem:**  
The `Order` model does not use the `SoftDeletes` trait. Deleted orders are permanently removed and cannot be audited, recovered, or referenced in historical financial reports.

**Fix:**  
1. Add `use SoftDeletes;` to `app/Models/Order.php`.  
2. Create a migration to add a `deleted_at` column to the `orders` table.  
3. Review any raw `Order::delete()` calls to confirm they should soft-delete rather than hard-delete.

---

### TASK-019 — Fix filter-active indicator to include `status` param

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-019 |
| **Status**  | Fixed — `status` param added to both filter-active conditions |
| **Severity**| Low |
| **Category**| UI / UX |
| **File**    | `resources/views/admin-views/refund/list.blade.php` |
| **Lines**   | 41–46 |

**Problem:**  
The filter button shows as active (blue with a red dot) only when `sort_by`, `from_date`, `to_date`, or `type` are present in the URL. The `status` parameter — which is pre-set when navigating from status-specific tabs — is not included in the condition. Admins on a filtered status view see no visual indication that a filter is active.

**Fix:**  
Add `!empty(request('status'))` to the condition on lines 41 and 45.

---

### TASK-020 — Add `DB::transaction()` to admin wallet updates in `OrderController`

| Field       | Detail |
|-------------|--------|
| **ID**      | TASK-020 |
| **Status**  | Already fixed — `orderReturnAmountToCustomer()` already wraps writes in `DB::beginTransaction()`/`commit()`/`rollBack()`; no code change needed |
| **Severity**| High |
| **Category**| Data Integrity |
| **File**    | `app/Http/Controllers/Admin/Order/OrderController.php` |
| **Lines**   | ~261–265 (`orderReturnAmountToCustomer`) |

**Problem:**  
Admin wallet balance updates in `orderReturnAmountToCustomer()` and related methods are performed without a surrounding `DB::transaction()`. If an error occurs after the wallet is updated but before the related order/edit records are saved, the wallet reflects a change that has no corresponding order record.

**Fix:**  
Wrap all inter-related wallet + order record updates in `DB::transaction()`.

---

## Recommended Fix Order

| Priority | Tasks | Reason |
|----------|-------|--------|
| **1 — Fix now** | TASK-001, TASK-002, TASK-003 | Direct money-loss risk in live refund processing |
| **2 — Fix now** | TASK-004, TASK-020 | Payment and wallet integrity |
| **3 — Fix soon** | TASK-005, TASK-006, TASK-007, TASK-008 | Authorization gaps open to any authenticated user |
| **4 — Fix soon** | TASK-009, TASK-010, TASK-012 | Input validation and business logic correctness |
| **5 — Next sprint** | TASK-011, TASK-013, TASK-014, TASK-015, TASK-016 | Stability, performance, and UX |
| **6 — Backlog** | TASK-017, TASK-018, TASK-019 | Code quality and minor UX |

---

## Resolution Summary (2026-07-09)

All 20 tasks were reviewed against the current codebase and addressed:

- **17 fixed** as described (TASK-001, 002, 003, 004, 005 [defense-in-depth scope], 006, 007, 008, 009, 010, 011, 012, 014, 015, 017, 018, 019).
- **2 already resolved** in the current code, no change needed (TASK-016, TASK-020).
- **1 ops-only task**, not a code fix (TASK-013) — added to the deployment checklist.

Several tasks diverged from their original description once checked against the live code (e.g. TASK-006, TASK-010, and TASK-020 were partially or fully already fixed; TASK-007's route was missing the `customer` middleware entirely, not just an ownership check) — see each task's updated Status line above for specifics.

In the same pass, M-Pesa was added as a payment gateway (both Daraja STK Push and C2B Paybill/Till), following the existing per-gateway controller/route pattern used by Razorpay, Bkash, etc.

---

*Report generated: 2026-06-25*
*Resolution pass: 2026-07-09*
