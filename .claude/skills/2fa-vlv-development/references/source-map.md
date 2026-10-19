# Source map

| Path | Role |
| --- | --- |
| `Sources/TwoFACore/Models.swift` | `Account`, `Folder`, `OTPKind`, `OTPAlgorithm` |
| `Sources/TwoFACore/Base32.swift` | RFC 4648 Base32 encode/decode/normalize |
| `Sources/TwoFACore/OTP.swift` | HOTP/TOTP/Steam generation, `secondsRemaining` |
| `Sources/TwoFACore/OTPAuthURI.swift` | parse/build `otpauth://` |
| `Sources/TwoFACore/LastPassImporter.swift` | LastPass Authenticator JSON to accounts + folders |
| `Sources/TwoFACore/AccountStore.swift` | persistence, sections, move, merge, folders |
| `Sources/TwoFACore/SecretStore.swift` | Keychain / in-memory secret stores |
| `Sources/TwoFAvlv/App/AppDelegate.swift` | windows, main menu, status item, popover, hotkey wiring |
| `Sources/TwoFAvlv/App/AppLocalization.swift` | `AppCopy` English + Spanish strings |
| `Sources/TwoFAvlv/App/AppBranding.swift` | name, version, URLs, icons |
| `Sources/TwoFAvlv/Services/*` | settings, clipboard, QR, lock, hotkey, login item |
| `Sources/TwoFAvlv/UI/*` | SwiftUI views and `AppState` |
| `scripts/*` | packaging and icon generation |
