# Publishing to pub.dev

This guide covers publishing `splashpay_sdk` to [pub.dev](https://pub.dev).

## Prerequisites

1. A [pub.dev](https://pub.dev) account
2. [Google Account linked](https://pub.dev/help#verified-publisher) (recommended for verified publisher)
3. Flutter SDK installed (`flutter --version`)
4. Git repository pushed to GitHub: `https://github.com/dukanitech/splashpay_sdk`

## Pre-publish checklist

Run these commands from the package root (`splashpay_sdk/`):

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

## Publish

```bash
cd splashpay_sdk
flutter pub publish
```

Review the file list, then confirm with `y`.

> First-time publishers must run `dart pub login` or `flutter pub login` before publishing.

## After publishing

1. Open https://pub.dev/packages/splashpay_sdk
2. Link the GitHub repository under **Package versions → Admin** for verified publisher
3. Tag the release in Git:

```bash
git tag v1.0.0
git push origin v1.0.0
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
| `package name already taken` | Choose a different name or claim ownership |
| `LICENSE missing` | Ensure `LICENSE` file exists at package root |
| `CHANGELOG missing` | Add `CHANGELOG.md` with version sections |
| `gitignored file would be published` | Add path to `.pubignore` |
| Low pub points | Add dartdoc comments to public APIs |

## Security reminder

Never publish API keys or secrets. The example `.env` file is gitignored and excluded via `.pubignore`.
