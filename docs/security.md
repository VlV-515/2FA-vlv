# Security

## Where data lives

| Data | Location |
| --- | --- |
| Account list, folders, order | `~/Library/Application Support/2FA-vlv/vault.json` (mode 0600) |
| Secret keys (default) | One macOS Keychain item: service `dev.vlv.2fa-vlv`, account `secrets`, this-device-only |
| Secret keys (Keychain off) | Inline in `vault.json` |
| Preferences | `UserDefaults` (no secrets) |

If Keychain writes fail, the app saves secrets in the vault file instead (so nothing is lost) and shows a warning.

## What the app does

- No network access. No analytics. No accounts.
- Copied codes use the concealed pasteboard type, so well-behaved clipboard managers skip them, and are cleared after a delay.
- Optional lock uses `LocalAuthentication` (Touch ID, Watch, or login password).
- Optional hidden codes protect against shoulder surfing.

## What it does not do

- It is not a password manager and does not encrypt `vault.json` when Keychain is off. Anyone with your user account and file access can read secrets in that mode.
- No encrypted export or cloud backup yet. Losing the Mac means losing the codes. Keep recovery codes.
- Builds are ad-hoc signed, not notarized.
- The LastPass backup you import contains plain secrets. Delete it after importing, or store it somewhere encrypted. This repo gitignores `data-example.json`.

## Reporting issues

Open an issue at <https://github.com/VlV-515/2fa-vlv/issues>. Do not paste real secrets or backups.
