# Commands

| Command | What it does |
| --- | --- |
| `swift build` | Debug build. |
| `swift test` | Runs `TwoFACoreTests`. |
| `swift run 2FA-vlv` | Runs the debug app from SwiftPM. |
| `./scripts/package-app.sh` | Release build and `dist/2FA-vlv.app` (ad-hoc signed). |
| `swift build && ./scripts/package-app.sh && open dist/2FA-vlv.app` | Build, package, launch. |
| `./scripts/package-release.sh 0.1.0` | `dist/2FA-vlv-0.1.0-macos-unsigned.zip` plus `.sha256`. |
| `./scripts/make-icns.sh` | Regenerates icon PNGs, iconset and `AppIcon.icns`. |

## Environment variables

| Variable | Used by | Default |
| --- | --- | --- |
| `APP_VERSION` | `package-app.sh` | `0.1.0` |
| `APP_BUILD` | `package-app.sh` | `1` |
| `CODESIGN_IDENTITY` | `package-app.sh` | `-` (ad-hoc) |
| `BUILD_NUMBER` | `package-release.sh` | `1` |
