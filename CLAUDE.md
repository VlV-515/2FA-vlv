# 2FA-vlv Agent Guide

- Always use the local `caveman` skill in `ultra` mode for this project.

Private-feel, open-source, Mac-only two-factor authenticator (Authy / LastPass Authenticator style).
Treat as a native macOS utility, not a web app.

## Start Here

- Read `.claude/rules/*.md` before editing source.
- Use `.claude/skills/2fa-vlv-development/SKILL.md` for implementation tasks.
- Use `.claude/agents/*.md` for specialized roles (engineer, docs, reviewer).
- UI work: use `ui-ux-pro-max` skill (design system already decided, see `docs/design.md`).
- Human docs live in `docs/`. Keep them in sync when behavior changes.

## Stack

- Swift Package Manager, swift-tools 5.9, macOS 13+.
- `TwoFACore` library: OTP engine, Base32, otpauth parser, LastPass importer, `AccountStore`, Keychain `SecretStore`. No UI imports. Unit tested.
- `TwoFAvlv` executable: AppKit lifecycle + SwiftUI views, services (lock, clipboard, QR, hotkey, login item).
- CryptoKit (HMAC), Security (Keychain), LocalAuthentication, CoreImage (QR), Carbon (hotkey), ServiceManagement.

## Commands

- `swift build` compile debug. Run before every commit.
- `swift test` run `TwoFACoreTests` (RFC 4226/6238 vectors, store, importer).
- `./scripts/package-app.sh` create `dist/2FA-vlv.app` (release build, Info.plist, ad-hoc sign).
- `swift build && ./scripts/package-app.sh && open dist/2FA-vlv.app` full run.
- `./scripts/make-icns.sh` regenerate icon assets from `scripts/make-icon.swift`.
- `./scripts/package-release.sh <version>` zip + sha256 for release.

Full reference: `docs/commands.md`.

## Git

- Commit small focused milestones, one concern each (`feat:`, `fix:`, `docs:`, `chore:`, `build:`).
- Do not push unless asked. Version tags `vX.Y.Z`. Current: `v0.1.0`.
- NEVER commit `data-example.json` (real LastPass backup, gitignored). Never print its secrets.

## Constraints

- UI language default English; every user-facing string goes through `AppCopy` (English + Spanish). No hardcoded literals in views.
- Every security/convenience feature stays optional via `AppSettings`.
- Secrets never in logs, never in `UserDefaults`, never in git. Keychain item holds all secrets in one blob.
- No Electron/Tauri/web. No network calls. No analytics.
- Do not enable iCloud/CloudKit without Apple Developer account.
- Do not run GUI app in automation unless user asks; smoke test = launch binary, wait, kill.

## Source Map

- `Sources/TwoFACore`: Models, Base32, OTP, OTPAuthURI, LastPassImporter, AccountStore, SecretStore.
- `Sources/TwoFAvlv/App`: Main, AppDelegate (windows, menus, status item), AppBranding, AppLocalization.
- `Sources/TwoFAvlv/Services`: AppSettings, ClipboardService, QRScanner, LockManager, HotKeyManager, LaunchAtLogin.
- `Sources/TwoFAvlv/UI`: AppState, Theme, RootView, AccountListView, AccountRowView, AccountEditorView, FoldersView, SettingsView, AboutView.
- `Tests/TwoFACoreTests`: core unit tests.
- `docs/`: human documentation.
