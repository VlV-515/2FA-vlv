# Installation

## Requirements

- macOS 13 (Ventura) or later.
- Swift 5.9+ toolchain (Xcode, or Command Line Tools: `xcode-select --install`).

## Build and run

```bash
git clone https://github.com/VlV-515/2fa-vlv.git
cd 2fa-vlv
swift build && ./scripts/package-app.sh && open dist/2FA-vlv.app
```

`package-app.sh` makes `dist/2FA-vlv.app` (release build, ad-hoc signed). Move it to `/Applications` if you like.

## First launch

The app is ad-hoc signed, not notarized. If macOS blocks it: right-click the app, choose **Open**, confirm.

On first use macOS may ask for:

- **Keychain access**, when secrets are saved. Choose **Always Allow**.
- **Screen Recording**, only when you use *Capture Screen Area* to scan a QR code.
- **Touch ID / password**, only if you enable the lock.

## Run without packaging

```bash
swift run 2FA-vlv
```

## Uninstall

Delete `2FA-vlv.app`. Optionally remove `~/Library/Application Support/2FA-vlv/` and the Keychain item `dev.vlv.2fa-vlv` (Keychain Access app). Your codes are gone after that, so keep your recovery codes.
