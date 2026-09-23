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
