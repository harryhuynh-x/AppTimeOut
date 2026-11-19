# AppTimeOut

Website for the AppTimeOut app.

## Repo setup

This is the **private** source repo — develop here, `git push origin main` as normal.

On every push to `main`, a GitHub Action (`.github/workflows/deploy.yml`) mirrors
the static site files to the **public** `harryhuynh-x/AppTimeOut` repo, which is
what GitHub Pages actually serves at apptimeout.com (via the `CNAME` file). The
public repo only ever receives clean "Deploy" commits — no dev history is exposed
there.

Requires a `PUBLIC_REPO_TOKEN` secret (fine-grained PAT, Contents: read/write,
scoped to `harryhuynh-x/AppTimeOut`) set in this repo's Actions secrets.

Do not edit `harryhuynh-x/AppTimeOut` directly — changes will be overwritten by
the next sync.

## Content rules and change log

- **Rules**: never promise un-bypassable blocking ("hard to talk yourself out of" is fine); no other-platform, pricing or free-trial claims in store creative; only mention app features that are live on the stores; no third-party hotlinked images; no third-party analytics (privacy policy says so).
- **11/05/2026** (`5fade52`): added the 1.7 features (overnight slots, streak and blocked-today total, lock status widget, lock summary, optional reminders) to the homepage and the schedule guide; made the "Does blocking work if I close the app?" FAQ platform-neutral; added the FAQ "Can I sign out or delete my account during a lock?" (also in the FAQPage JSON-LD); `delete-account.html` now explains that deleting an account or signing out waits until an active lock ends.
- **11/18/2026 homepage refresh for conversion** (generic-icon art only): new hero phone trio (Reports / Dashboard / Manage Blocks), 3-step 'Up and running in one minute' strip, new 'See the hours you got back' Reports section, 'See it in action' iPhone/Android gallery (`Photos/gallery/`, store art from the iOS/Android repos), final download CTA with `ct=website_bottom` / `utm_medium=bottom` tracking, new `og-image.png`, JSON-LD `screenshot`. All phone images in `Photos/` are regenerated from the 2.0 captures (`Scripts/marketing/assets/captures-v3/pro/` in the iOS repo). RULE: no real third-party app logos/names in any image (iOS 2.0 was rejected for it, Guideline 2.3.14). Cropped `reports.webp`/`buddy.webp` (660x960 / 660x840) on purpose to hide blank screen areas.
- **11/18/2026 How To page**: all 5 step images are now 2.0 captures (Step 4 = Schedule card with Enable Self-Lock/Buddy-Lock buttons, Step 5 = 'Buddy Lock is Active' sheet cropped to content). Captured with `xcodebuild test -only-testing:AppTimeOutUITests/AppStoreScreenshots/test_06_buddyUnlock` (+ test_08_codeSent) on iPhone 17 Pro; sources kept in the iOS repo `Scripts/marketing/assets/captures-v3/pro/`. Fixed Step 5 layout (missing `.feature-row > .feature-row-inner` flex rule).
- **Deploy check**: after a push, the Action finishes in ~12 s; the live site can take up to a minute to show the change.


## Search Console indexing report — what is expected (checked 11/12/2026)

Property: **URL-prefix** `https://apptimeout.com/` (the `sc-domain:` form shows "no access"). On 11/12 it listed 8 indexed / 6 not indexed. The Google email "New reasons preventing your pages from being indexed" (11/11) was about these, all benign:

| Reason | URL(s) | Verdict |
|---|---|---|
| Excluded by 'noindex' tag (3) | `/get/?c=…` campaign links | **Intentional.** `/get/index.html` is the store-redirect page and is `noindex` on purpose (also `404.html`). Never remove it. |
| Alternate page with proper canonical tag (1) | `/?from=AppAgg.com&utm_…` | **Correct.** Tracking-suffix copy of the homepage; the page's canonical points to `https://apptimeout.com/`. |
| Duplicate without user-selected canonical (1) | `/index.html` | Cause found: `privacy.html` / `delete-account.html` linked to `index.html`. **Fixed 11/12** (links now `/`). The live `index.html` already has the canonical, so Google should reclassify it on its next crawl. |
| Crawled – currently not indexed (1) | `/block-apps-iphone/` | Google's quality/priority call (page is ~390 words, same as the Android guide). Not an error. Page is linked from the homepage and all guides and is in the sitemap. **Request indexing submitted 11/12/2026** ("added to a priority crawl queue"; last crawl was Nov 1, fetch OK, canonical OK). Check again in ~1–2 weeks; if still not indexed, add unique content to the page. |

Rules to keep: link to the homepage as `/` (never `index.html`); every indexable page keeps a self-referencing `<link rel="canonical">` with the `https://apptimeout.com/...` form; only `404.html` and `get/` are `noindex`; campaign links go through `/get/?c=…` or `?src=…`. Untracked `.claude/worktrees/` folders on this machine are not deployed (the Action ships tracked files only).
