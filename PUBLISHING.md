# Publishing to pub.dev

This guide covers publishing `splashpay_sdk` under the verified publisher **[dukanitech.com](https://pub.dev/publishers/dukanitech.com/packages)**.

## Publisher

| Field | Value |
|-------|-------|
| Publisher | [dukanitech.com](https://pub.dev/publishers/dukanitech.com/packages) |
| Package | https://pub.dev/packages/splashpay_sdk |
| Repository | https://github.com/dukanitech/splashpay_sdk |

## Prerequisites

1. A [pub.dev](https://pub.dev) account linked to a Google Account
2. Membership as **admin** of the `dukanitech.com` verified publisher
3. Flutter SDK installed (`flutter --version`)
4. Git repository pushed to GitHub

## Transfer package to dukanitech.com (first time only)

If the package was published under a personal account, transfer it to the verified publisher:

1. Sign in to pub.dev with the Google Account that uploaded the package
2. Open https://pub.dev/packages/splashpay_sdk/admin
3. Under **Transfer to publisher**, enter: `dukanitech.com`
4. Click **Transfer to Publisher**

> **Warning:** This cannot be undone. After transfer, all `dukanitech.com` publisher members can publish updates.

Once transferred, the package appears at:
https://pub.dev/publishers/dukanitech.com/packages

## Pre-publish checklist

Run these commands from the package root:

```bash
flutter pub get
flutter analyze
flutter test
flutter pub publish --dry-run
```

Confirm:

- [ ] `CHANGELOG.md` is updated for the new version
- [ ] `pubspec.yaml` `version` is bumped (semver)
- [ ] No secrets in source, tests, README, or example `.env`
- [ ] `LICENSE` is present (MIT)
- [ ] `README.md` documents installation and usage
- [ ] Example app has `publish_to: 'none'` in `example/pubspec.yaml`

## Publish updates

After the package belongs to `dukanitech.com`, publish new versions with:

```bash
cd splashpay_sdk
flutter pub login
flutter pub publish
```

Review the file list, then confirm with `y`.

> You must be logged in as a `dukanitech.com` publisher member.

## After publishing

1. Verify the package shows **verified publisher dukanitech.com** on https://pub.dev/packages/splashpay_sdk
2. Confirm it appears on https://pub.dev/publishers/dukanitech.com/packages
3. Tag the release in Git:

```bash
git tag v1.0.1
git push origin v1.0.1
```

## Installing the published package

```yaml
dependencies:
  splashpay_sdk: ^1.0.0
```

```bash
flutter pub get
```

## Version bumps

Follow [semantic versioning](https://semver.org/):

| Change | Version bump |
|--------|----------------|
| Bug fix | `1.0.1` |
| New feature (backward compatible) | `1.1.0` |
| Breaking change | `2.0.0` |

Update `CHANGELOG.md` before each release.

## CI

GitHub Actions runs `flutter analyze` and `flutter test` on push/PR to `main`.
See `.github/workflows/ci.yml`.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `package name already taken` | Package already exists — publish a new version instead |
| `not authorized to publish` | Ensure you are a `dukanitech.com` publisher member |
| Transfer option missing | You must be package uploader AND publisher admin |
| `LICENSE missing` | Ensure `LICENSE` file exists at package root |
| `CHANGELOG missing` | Add `CHANGELOG.md` with version sections |
| Low pub points | Add dartdoc comments to public APIs |

## Security reminder

Never publish API keys or secrets. The example `.env` file is gitignored and excluded via `.pubignore`.
