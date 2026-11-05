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
- **Deploy check**: after a push, the Action finishes in ~12 s; the live site can take up to a minute to show the change.

