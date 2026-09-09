# MeatSoko — UX Revamp Mockup

Static HTML design mockup for the MeatSoko homepage revamp: 14 pages covering the full shopping flow (home, category, product, cart, checkout, order confirmation, categories overview, search, track order, login/register, account, about, contact, FAQ).

No build step — plain HTML/CSS with fonts embedded inline. Images are hotlinked from the live site (`shop.meatsokogroup.com`), so an internet connection is needed to see them load.

## Deploy to Vercel

**Option A — Vercel CLI (fastest, no GitHub needed):**
```
npm i -g vercel      # if you don't already have it
cd meatsoko-mockup
vercel               # first run: log in, confirm project settings
vercel --prod        # deploy to production, prints a shareable URL
```

**Option B — Drag and drop:**
Go to [vercel.com/new](https://vercel.com/new), and drag the `meatsoko-mockup` folder onto the page. No account setup beyond logging in.

**Option C — GitHub integration:**
Push this folder to a new GitHub repo, then import it at [vercel.com/new](https://vercel.com/new). Every push redeploys automatically.

## Notes

- Visiting the deployed root URL (`/`) shows the homepage — `vercel.json` rewrites `/` → `/home.html`.
- Every other page is reachable directly by filename, e.g. `/cart.html`, `/checkout.html`.
- All pages cross-link to each other (nav bar, header icons, footer, in-page CTAs), so once deployed the whole flow is click-through navigable from the live URL.
