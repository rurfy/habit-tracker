# Releasing

## Web

Merged to `main` with a green CI automatically triggers the **deploy-web** workflow.  
It builds with `--base-href /habit-tracker/` and publishes to `gh-pages`.

## Android

- Configure local signing or use CI secrets if you wire up Play Store.
- Trigger the `release-android.yml` workflow (tag or manual dispatch).

## iOS

- Requires a valid signing setup (manual or CI).
- Trigger the `release-ios.yml` workflow.

## Versioning

- Update `version:` in `frontend/pubspec.yaml`.
- Use Conventional Commits; release notes can be auto‑generated later.
