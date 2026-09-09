# Profile ("More") Page Cleanup Plan — user_app

**Date:** 2026-09-09
**Source file:** `user_app/lib/features/more/screens/more_screen_view_new.dart` (`MoreScreenView`, appears in the app as the "Profile" tab — `AppBar` title reads `getTranslated('profile', ...)`).
**Method:** Read the full 975-line file end to end and catalogued every item actually present in the widget tree (not just what's visually obvious), including auth-gated and config-gated ones that only render conditionally.

## 1. Full current inventory

37 distinct entries today, in on-screen order. "Gated" means it only appears under some condition — those aren't a display bug, just easy to miss when eyeballing the page in one state.

**Profile card (not a list item, but the top block):** tap → My Profile if logged in, else Login.

**Top-level (always visible, outside any group):**
1. My Profile → profile screen
2. Notification → notification screen (badge: unread count)
3. Settings → settings screen
4. **Payment** → Wallet screen (badge: wallet balance)

**"Shopping" group (collapsible):**
5. Cart
6. Wishlist
7. Offers
8. Coupons
9. Compare Products
10. **Category** → Categories browse screen
11. Restock Requests *(gated: logged in)*
12. Blog *(gated: `blogUrl` configured server-side)*

**"Orders & Wallet" group (collapsible):**
13. Order History
14. Track Order *(routes through the **guest** track-order flow even when logged in)*
15. **Wallet** → Wallet screen (badge: wallet balance)
16. Loyalty Points (badge: points)
17. Refer & Earn *(gated: `refEarningStatus == '1'`)*

**"Help & Support" group (collapsible):**
18. Support Ticket
19. FAQ
20. Inbox
21. Contact Us
22. About Us *(gated: an `about-us` business page exists)*
23. **[dynamic]** any other custom business pages the admin has added *(gated: `businessPages` list non-empty; icon is currently the loyalty-points icon regardless of what the page is — a labeling bug, not a real "item")*
24. Terms and Conditions
25. Privacy Policy
26. Refund Policy *(gated: page exists)*
27. Return Policy *(gated: page exists)*
28. Cancellation Policy *(gated: page exists)*
29. Shipping Policy *(gated: page exists)*

**Top-level (after the groups):**
30. Sign Out

**"Bidding Activity" + "My Auctions" — flat sections, not collapsible groups, *entirely gated* on the auction feature being enabled:**
31. My Bids (badge: count)
32. Saved Auction (badge: count)
33. Create Auction *(further gated: `isActiveAuctionForCustomer`)*
34. All Auctions (badge: count)
35. Auction Request List (badge: count)
36. Auction Sales Report
37. Auction Transaction History

## 2. What's actually wrong

### 2.1 Confirmed duplicate: Payment (#4) = Wallet (#15)
Not just similarly named — **identical feature shown twice.** Same icon (`Images.walletIcon`), same destination (`RouterHelper.getWalletRoute`), same wallet-balance trailing badge, same login-gate logic. One is a top-level item; the other is buried inside "Orders & Wallet." A user has no way to tell these apart until they tap both and land on the same screen.

**Recommendation:** keep one. I'd keep it **top-level** (as "Wallet" — that's the more accurate name for what it actually shows, a balance + wallet screen, not a payment-methods manager) since balance is worth surfacing without an extra tap, and delete the copy inside "Orders & Wallet." No information is lost — same route, same data, still reachable, just from one place instead of two.

### 2.2 "Category" (#10) doesn't belong on an account page
It's a pure catalog-browse shortcut, not account/settings-related, sitting inside the "Shopping" group. It's also fully redundant with navigation that already exists elsewhere in the app: Categories is a first-class bottom-nav destination with its own search, banners, and browse UI (recent work in this same session built that out — inline live search, banner carousel, etc.). Nothing here is unique to this entry.

**Recommendation:** remove it from this page entirely. Nothing is lost — same screen, same route, already one tap away from the bottom nav on every screen in the app, including this one.

### 2.3 Worth a decision, not a clear-cut removal: Track Order (#14)
Sits in "Orders & Wallet" right next to "Order History," but routes through the **guest** track-order flow (`getGuestTrackOrderRoute`) even for a logged-in user who already has "Order History" one row above it. These may be intentionally different (quick order-number lookup vs. browsing your full order list) rather than true duplicates — I'm flagging this as something to verify with whoever owns the order-tracking UX, not asserting it should go. If it *is* meant to be the same lookup, merge it into Order History; if it's deliberately a fast-path (e.g., for tracking someone else's order, or one placed as a guest before logging in), keep it but the label/placement could be clearer about why it's separate.

### 2.4 Structural inconsistency: two different grouping patterns on one page
Everything from "Shopping" through "Help & Support" uses the same collapsible `SettingsGroup` (an `ExpansionTile`). The auction section (#31-37) instead uses flat `SectionHeader` labels with no collapse behavior, and sits outside the card that contains everything else. When the auction feature is off, this is invisible and harmless; when it's on, the page reads as two visually different systems bolted together.

**Recommendation:** fold "Bidding Activity" and "My Auctions" into the same card, using the same `SettingsGroup` pattern as the other four groups (e.g., one collapsible "Auctions" group containing both). Nothing removed — same 7 items, same gating, just visually consistent with the rest of the page.

### 2.5 Found while reading, not part of "duplicate/unnecessary" but worth fixing in the same pass
These aren't clutter, they're bugs — flagging so they don't get silently carried into whatever the "cleaned up" version becomes:
- **6 dead links.** About Us, the dynamic custom-business-pages list, Refund Policy, Return Policy, Cancellation Policy, and Shipping Policy all still call `RouterHelper.getHtmlViewRoute(...)` directly in `onTap` without wrapping it in `context.push(...)` — that method only returns a route string, it doesn't navigate. This is the exact bug already found and fixed for Terms & Conditions and Privacy Policy earlier in this project; it was never applied to these six. Right now, tapping any of them does nothing.
- **Wrong `fromPage` on three "not logged in" prompts.** Wishlist (#6), the duplicate Wallet entry (#15), and Loyalty Points (#16) all pass `fromPage: RouterHelper.auctionQueueListScreen` to the "please log in" bottom sheet — an auction route that has nothing to do with any of these three. Looks like a copy-paste from the auction section that never got updated. Affects where the user lands after logging in from that prompt.
- **Mislabeled icon for custom business pages** (#23) — reuses `Images.loyaltyPointsIcon` for whatever arbitrary page the admin added, regardless of what it actually is.

## 3. Proposed cleaned-up structure

Everything below is either kept as-is, merged (with the surviving entry doing the same job), or relocated to where it's already available elsewhere — nothing is dropped without an equivalent still existing in the app.

**Top-level:**
1. My Profile
2. Notification
3. Settings
4. Wallet *(was "Payment" — kept top-level, absorbs the duplicate)*

**"Shopping" group:** Cart, Wishlist, Offers, Coupons, Compare Products, Restock Requests *(gated)*, Blog *(gated)* — **Category removed** (already on the bottom nav).

**"Orders & Wallet" group:** Order History, Track Order *(pending the decision in §2.3)*, Loyalty Points, Refer & Earn *(gated)* — **Wallet entry removed** (now top-level, #4).

**"Help & Support" group:** unchanged — Support Ticket, FAQ, Inbox, Contact Us, About Us *(gated)*, custom pages *(gated)*, Terms and Conditions, Privacy Policy, Refund/Return/Cancellation/Shipping Policy *(each gated)*.

**"Auctions" group *(gated on the feature flag, now a collapsible group matching the others instead of flat sections)*:** My Bids, Saved Auction, Create Auction *(further gated)*, All Auctions, Auction Request List, Auction Sales Report, Auction Transaction History.

**Sign Out** — unchanged, stays last.

Net change: **37 → 35 entries** (one true duplicate removed, one misplaced navigation shortcut removed), plus one section restructured for visual consistency and three bugs fixed along the way (dead links, wrong post-login redirect, mislabeled icon) so the "cleaned up" page isn't also a "still broken in six places" page.

## 4. Open question for you before I implement anything

Only §2.3 (Track Order vs. Order History) needs a decision — everything else in §3 I'm confident is a safe, information-preserving cleanup. Let me know how you want Track Order handled and whether to go ahead with the rest.
