# MeatSoko E-commerce Website — UX Status Report

**Review basis:** Live-site review of the current MeatSoko storefront, supplemented by the supplied Claude Code technical review.
**Purpose:** Establish the current UX status and identify issues requiring attention before launch.

**Priority:**

* **P0:** Launch blocker
* **P1:** High priority; should be fixed before launch where possible
* **P2:** Improvement that can follow launch

---

## 1. Homepage

### What it contains

* Search.
* Sign in/sign up.
* Shopping cart.
* Extensive category navigation.
* Featured products.
* Product categories.
* Top sellers.
* Latest products.
* New arrivals.
* Best-selling products.
* Top-rated products.
* Brands.
* Delivery/payment/returns trust statements.
* About Us, Contact, FAQ and policy links.
* Newsletter and support/contact information. ([MeatSoko][1])

### What it does well

* Provides several routes into the catalogue.
* Makes the product catalogue and major categories visible.
* Provides clear access to search and cart.
* Displays KES pricing.
* Includes trust signals such as delivery, payment, returns and authenticity.
* Provides contact information and policy links. ([MeatSoko][1])

### What needs improvement

* The homepage is heavily catalogue/navigation-driven rather than strongly communicating **why customers should buy from MeatSoko**.
* The current catalogue contains very different product types: food, veterinary products, feeds, equipment, live animals and services. This creates a broad information architecture that can make the primary shopping journey less focused. ([MeatSoko][2])
* The homepage currently has only one visible product repeatedly appearing across featured/latest/best-selling/top-rated sections: **Whole Goat (Large), KES 13,900**. This makes several sections appear repetitive rather than genuinely useful. ([MeatSoko][1])
* "Top sellers", "Top rated" and seller sections show zero reviews for the visible sellers/product ecosystem, reducing their usefulness as social proof. ([MeatSoko][1])

**Priority: P1**

---

# 2. Navigation & Information Architecture

### What it contains

The navigation currently covers:

* Dairy
* Meat
* Health/veterinary
* Poultry
* Equipment
* Services
* Feeds
* Livestock

Each contains multiple subcategories and, in many cases, further product-level categories. ([MeatSoko][2])

### What it does well

* Categories are logically grouped at a high level.
* Meat is divided into recognisable sections such as beef, mutton/goat, poultry meat, minced meat and offal.
* Subcategories provide potentially useful product-level discovery. ([MeatSoko][2])

### What needs improvement

* The number and depth of categories creates significant navigation complexity.
* Consumer meat shopping and agricultural/B2B shopping are currently presented within the same primary structure.
* Category naming is not always consistent in style, e.g. **"Equipments"**, **"Livestock(Live Animals)"**, and mixed descriptive conventions.
* The information architecture should be validated against the site's intended primary audiences.

**Priority: P1**

---

# 3. Search

### What it contains

* Search field is available globally and on the product listing experience. ([MeatSoko][2])

### What it does well

* Search is accessible without requiring users to navigate through the full category structure.

### What needs improvement

* Search relevance, typo tolerance, autocomplete and product-result quality require functional testing.
* Search should provide a useful recovery path when no results are found.
* Search is particularly important because the current category structure is large.

**Priority: P1 — functional behaviour should be verified before launch.**

---

# 4. Category & Product Listing Pages

### What it contains

* Product count.
* Search within products.
* Sorting.
* Product type filtering.
* Price filtering.
* Category filtering.
* Brand filtering.
* Product results. ([MeatSoko][2])

### What it does well

* The listing architecture contains the expected e-commerce discovery controls.
* Price filtering uses KES.
* Users have multiple ways to narrow products. ([MeatSoko][2])

### What needs improvement

**P0 — Product discoverability/data integrity issue.**

Live testing shows:

| Page                    | Result                                        |
| ----------------------- | --------------------------------------------- |
| `/products`             | 1 item found — Whole Goat (Large), KES 13,900 |
| Meat                    | 0 items found                                 |
| Mutton & Goat Meat      | 0 items found                                 |
| Full Whole Goat Carcass | 0 items found                                 |
| Product page            | Loads and is buyable                          |

The product breadcrumb identifies the product as **Meat → Mutton & Goat Meat → Full Whole Goat Carcass**, yet all three relevant category pages return no product. ([MeatSoko][2])

This means a customer can potentially find and purchase the product through the general catalogue but fail to find it by navigating through its assigned category.

### Technical assessment

* The supplied Claude Code review identified a real parent-category aggregation defect in `ProductManager.php:2584`.
* However, that defect alone does not explain the leaf-category failure.
* The stronger current hypothesis is a **product/category data relationship mismatch**.
* Database/admin verification is required to confirm the exact root cause and determine whether multiple products are affected.

**Priority: P0**

---

# 5. Product Page

### What it contains

The tested product page includes:

* Product name.
* Price.
* Quantity controls.
* Buy Now.
* Add to Cart.
* Restock request.
* Product description.
* Product images.
* Seller information.
* Reviews.
* Delivery/payment/return/authenticity signals. ([MeatSoko][3])

### What it does well

* Clear product name and KES price.
* Quantity can be adjusted.
* Buy Now and Add to Cart actions are immediately available.
* Product description gives meaningful information about what the whole goat includes.
* Product has multiple images.
* Seller information is available. ([MeatSoko][3])

### What needs improvement

* The product provides limited structured information about **weight, expected yield, preparation/cutting options, freshness, packaging and delivery conditions**.
* There are currently **0 reviews** on the tested product.
* The product description is useful but is aimed partly at commercial buyers and could more clearly explain the consumer purchase.
* Meat products require especially clear unit/weight information because customers need to understand exactly what the listed price represents.
* "7 Days Return Policy" is displayed, but the practical applicability of returns to fresh/perishable meat should be clearly explained. ([MeatSoko][3])

**Priority: P1**

---

# 6. Cart

### What it contains

* Shopping cart is available globally.
* Empty-cart state clearly informs the user that no products have been added. ([MeatSoko][2])

### What it does well

* Cart is consistently accessible.
* Empty state is understandable.

### What needs improvement

* Full cart behaviour needs functional testing with an actual product.
* Verify quantity editing, subtotal, delivery charges, total price, removal and persistence.
* Ensure pricing remains consistent between product page, cart and checkout.

**Priority: P1 — requires end-to-end verification.**

---

# 7. Checkout

### What it contains

The current public crawl confirms the shopping/cart infrastructure, but a complete checkout transaction was not independently verified during this review.

### What it does well

* The platform provides an e-commerce purchase flow and product-level Buy Now/Add to Cart actions. ([MeatSoko][3])

### What needs improvement / verification

Before launch, verify:

* Guest checkout vs mandatory registration.
* Delivery address flow.
* Delivery fee calculation.
* Order summary.
* Payment methods.
* M-Pesa/payment confirmation.
* Validation and error handling.
* Failed-payment recovery.
* Order confirmation.
* Order tracking.
* Customer notification.

**Priority: P0 until the complete purchase flow has passed end-to-end testing.**

---

# 8. Delivery

### What it contains

The site currently states **"Fast Delivery all across the country."** ([MeatSoko][1])

### What it does well

* Delivery is communicated as a core service benefit.
* The site provides a Track Order link. ([MeatSoko][1])

### What needs improvement

The current messaging does not clearly communicate:

* Delivery charges.
* Specific delivery locations/coverage rules.
* Expected delivery time.
* Same-day/next-day availability.
* Handling of chilled/fresh meat.
* Packaging/cold-chain information.
* What happens if a delivery cannot be fulfilled.

"Fast Delivery all across the country" is too broad on its own for a fresh-food purchase. ([MeatSoko][1])

**Priority: P0**

---

# 9. Payment

### What it contains

* The site communicates **"Safe Payment."** ([MeatSoko][1])

### What it does well

* Payment security is positioned as a trust benefit.

### What needs improvement

* Payment methods should be explicitly visible before payment.
* M-Pesa should be clearly presented if supported.
* Customers should know exactly when payment is completed and what happens after successful/failed payment.
* Payment failure and retry behaviour requires testing.

**Priority: P0 — payment must be verified end-to-end before launch.**

---

# 10. Customer Accounts

### What it contains

* Sign in.
* Sign up.
* Profile information.
* Wishlist functionality.
* Address management.
* Order tracking.
* Support ticket functionality. ([MeatSoko][2])

### What it does well

* The platform has a reasonable account foundation.
* Address and order-related functionality exists.

### What needs improvement

* Determine whether customers are unnecessarily forced to create accounts before purchasing.
* Account-related features should not obstruct the primary purchase journey.
* Verify password recovery, address management and order-history usability.

**Priority: P1**

---

# 11. Trust & Credibility

### What it contains

The site communicates:

* Fast delivery.
* Safe payment.
* 7-day return policy.
* 100% authentic products.
* About Us.
* Contact Us.
* FAQ.
* Terms.
* Privacy Policy.
* Refund, return and cancellation policies.
* Phone and email contact details. ([MeatSoko][1])

### What it does well

* Multiple trust signals are present.
* Contact information is visible.
* Legal/policy documentation is linked.

### What needs improvement

For a meat marketplace, trust should be more specific to the product:

* Freshness standards.
* Food-safety practices.
* Packaging.
* Cold-chain handling.
* Source/traceability.
* Halal availability where applicable.
* Seller verification.
* Actual customer reviews.
* Clear refund/return rules for perishable goods.

**Priority: P1**

---

# 12. Reviews & Social Proof

### What it contains

* Product reviews.
* Seller reviews.
* Top-rated products.
* Top sellers. ([MeatSoko][1])

### What it does well

* The infrastructure for reviews and ratings exists.

### What needs improvement

* The current visible ecosystem has effectively no social proof: the tested product has **0 reviews**, and listed sellers show **0 reviews**. ([MeatSoko][1])
* "Top rated" and "Top sellers" sections therefore currently provide little decision-making value.
* If the platform is new, these sections should not imply established popularity without supporting data.

**Priority: P1**

---

# 13. Mobile Experience

### What it contains

The site provides responsive e-commerce functionality, including navigation, search, cart, product pages and account functionality.

### What it does well

* The core shopping architecture is suitable for mobile use.

### What needs improvement

A dedicated mobile usability pass is still required for:

* Navigation depth.
* Category menus.
* Search.
* Product image sizing.
* Sticky/visible purchase actions.
* Filter controls.
* Cart.
* Checkout forms.
* Payment.
* Touch-target sizing.
* Page loading/perceived performance.

**Priority: P0/P1 — must be tested on actual mobile devices before launch.**

---

# 14. Accessibility

### What it contains

* Text navigation, forms, buttons, product controls and image elements.

### What it does well

* Core functionality is represented with text labels in many areas.

### What needs improvement

A formal accessibility test should verify:

* Colour contrast.
* Keyboard navigation.
* Focus states.
* Form labels.
* Error messaging.
* Image alternative text.
* Heading hierarchy.
* Screen-reader behaviour.
* Touch target sizes.

**Priority: P1**

---

# 15. Content & Copy

### What it contains

The site uses product/category descriptions and supporting e-commerce messaging.

### What it does well

* Product names are generally descriptive.
* Local terminology is used appropriately in places, e.g. Matumbo and KES pricing.
* The site supports English and Swahili language selection. ([MeatSoko][2])

### What needs improvement

* Naming conventions should be standardised.
* Some terminology is awkward or inconsistent, e.g. **"Equipments"**.
* Product copy should consistently answer: **What is it? How much is it? What exactly do I receive? How is it packaged? When will I receive it?**
* Perishable-product language needs greater precision.

**Priority: P1**

---

# 16. Technical UX Issues

### Confirmed

* Category/product visibility is inconsistent.
* The general catalogue returns the tested product while its assigned category hierarchy returns zero products. ([MeatSoko][2])
* Claude Code identified a parent-category aggregation defect in `ProductManager.php:2584`.

### Likely underlying issue

* Product/category foreign-key or category-assignment mismatch.

### Required technical action

* Inspect the product's stored category, subcategory and sub-subcategory IDs.
* Compare them directly with the relevant category records.
* Audit other products for the same mismatch.
* Fix the underlying relationship rather than manually correcting only the visible product.
* Retest parent, mid-level and leaf categories after the fix.

**Priority: P0**

---

# 17. Overall Launch Status

### Current strengths

* Core e-commerce infrastructure exists.
* Search, categories, filters, sorting, accounts, cart and product purchasing are present.
* Product pages have clear purchase actions.
* The site has a broad product catalogue.
* Local KES pricing and Kenyan contact information are present.
* Trust, policy and support infrastructure exists. ([MeatSoko][2])

### Main launch risks

**P0 — Must resolve**

1. Product/category discoverability mismatch.
2. Parent-category aggregation defect.
3. Complete checkout flow verification.
4. Payment/M-Pesa verification.
5. Delivery coverage, pricing and timing clarity.
6. Fresh-meat delivery/handling information.
7. Full mobile purchase-flow testing.

**P1 — Should resolve before launch**

1. Simplify/clarify information architecture.
2. Improve product information, especially weight/quantity and freshness.
3. Strengthen trust and food-safety information.
4. Improve review/social-proof presentation.
5. Standardise category and product terminology.
6. Complete accessibility testing.
7. Validate account flow and guest purchasing.

**P2 — Post-launch opportunities**

1. Meat bundles and family packs.
2. Nyama choma packs.
3. Freezer packs.
4. Wholesale/B2B purchasing.
5. Personalised recommendations.
6. More sophisticated merchandising and promotional sections.

---

# Final Assessment

MeatSoko now has a **substantial e-commerce foundation**, but the current experience is not yet consistently reliable enough to treat the site as launch-ready.

The most serious issue is not visual polish; it is **product discoverability and transaction confidence**. A customer must be able to reliably find a product through its category, understand exactly what they are purchasing, know when and how it will be delivered, pay successfully, and receive clear confirmation.

The immediate priority should therefore be:

**Fix catalogue integrity → verify checkout/payment → clarify delivery → strengthen product/trust information → validate mobile → then refine the broader UX.**

At present, the site should be considered **P0/P1 remediation required before launch**, rather than simply a final visual-polish exercise.

[1]: https://shop.meatsokogroup.com/ "MeatSoko Online Shopping | MeatSoko Ecommerce"
[2]: https://shop.meatsokogroup.com/products "Products"
[3]: https://shop.meatsokogroup.com/product/whole-goat-large-McMwA5 "Whole Goat (Large)"
