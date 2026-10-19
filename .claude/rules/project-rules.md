# Project rules

- Product: simple, open-source, offline authenticator for macOS. Prefer fewer features done well.
- Keep core logic in `TwoFACore` (testable, no AppKit/SwiftUI). Views stay thin.
- New user-facing text: add a property to `AppCopy` with English and Spanish. Never hardcode in a view.
- New optional behavior: add a key to `AppSettings`, default to the safest option, expose in Settings.
- Add a unit test for every change in `TwoFACore`. OTP changes must keep RFC vectors passing.
- Never log or print secrets, codes, or the contents of backup files.
- Keep `data-example.json` out of git and out of fixtures; tests use synthetic data.
- Update `docs/` and README when behavior, settings or commands change.
- Version lives in `scripts/package-app.sh` and `scripts/package-release.sh` defaults plus `AppBranding` fallback. Bump all together.
