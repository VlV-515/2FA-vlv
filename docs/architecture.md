# Architecture

Swift Package with three targets.

```
TwoFACore   (library, no UI)   <-- TwoFACoreTests
TwoFAvlv    (executable)  --> TwoFACore
```

## TwoFACore

- `Account`, `Folder`, `OTPKind` (totp/hotp/steam), `OTPAlgorithm` (SHA1/256/512).
- `Base32`: decode/encode/normalize/validate.
- `OTP`: RFC 4226 truncation over CryptoKit HMAC; TOTP counter = floor(t / period); Steam alphabet `23456789BCDFGHJKMNPQRTVWXY`.
- `OTPAuthURI`: parse and build `otpauth://` links.
- `LastPassImporter`: LastPass Authenticator JSON to accounts and folders. Folder ids 0 and 1 are built-ins and are skipped.
- `AccountStore` (`ObservableObject`): load/persist, sections (favorites, folders, unfiled), move, merge, folder CRUD. Chooses Keychain or inline secrets.
- `SecretStoring`: `KeychainSecretStore` (single item) and `MemorySecretStore` (tests).

## TwoFAvlv

- `App/AppDelegate`: creates the main, settings and about windows, builds the main menu, owns the status item and popover, registers the hotkey, reacts to settings changes via Combine.
- `UI/AppState`: shared actions (copy, import, requests to open editor/folders), toast, alerts.
- `Services/`: `AppSettings` (UserDefaults), `LockManager`, `ClipboardService`, `QRScanner`, `HotKeyManager`, `LaunchAtLogin`.
- `UI/`: SwiftUI views. Every row owns a `TimelineView` (0.25 s) so only visible rows recompute codes and dragging stays smooth.
- `App/AppLocalization`: `AppCopy`, all strings in English and Spanish.

## Data flow

```
View --action--> AppState / AccountStore --persist--> vault.json (+ Keychain)
AccountStore --@Published--> SwiftUI
AppSettings --Combine--> AppDelegate (menu, status item, hotkey)
```

## Tests

`swift test` covers RFC 4226 and RFC 6238 vectors (SHA1/256/512), Base32, URI parsing, LastPass import, and the store (persistence modes, fallback, sections, move, merge).
