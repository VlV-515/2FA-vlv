---
name: 2fa-vlv-development
description: Develop, test, package and document the 2FA-vlv macOS authenticator (Swift Package, SwiftUI + AppKit, TwoFACore). Use for any implementation task in this repo.
---

# 2FA-vlv development

## Workflow

1. Read `CLAUDE.md`, `.claude/rules/*.md` and `references/source-map.md`.
2. Core change? Edit `Sources/TwoFACore`, add a test in `Tests/TwoFACoreTests`.
3. UI change? Edit `Sources/TwoFAvlv/UI`; add copy to `AppCopy`; use `Theme` tokens.
4. New option? Add to `AppSettings`, wire reaction in `AppDelegate`/`AppState`, expose in `SettingsView`.
5. `swift build && swift test`, then `./scripts/package-app.sh` if launch/packaging changed.
6. Update `docs/` and commit (`type(scope): summary`).

## Gotchas

- `Account.secret` is empty on disk when Keychain is used; `AccountStore` rehydrates on `load()`.
- HOTP code does not auto-increment on copy; the refresh button calls `incrementCounter`.
- Steam codes: SHA1, 5 chars from a custom alphabet, period 30.
- LastPass folder ids 0 and 1 are built-ins ("Otras cuentas", "Favoritos"), not real folders.
- `CIDetectorTypeQRCode` is the detector constant (not `...QR`).
- Do not take GUI screenshots in automation; smoke test by launching the binary and killing it.
