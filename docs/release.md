# Release

Version scheme: `MAJOR.MINOR.PATCH`. First release: `v1.0.0` (first public build).

## Checklist

1. Update version defaults in `scripts/package-app.sh`, `scripts/package-release.sh` and the fallback in `Sources/TwoFAvlv/App/AppBranding.swift`.
2. Add `.github/release-notes/vX.Y.Z.md`.
3. `swift build && swift test`.
4. `./scripts/package-release.sh X.Y.Z`.
5. Commit: `chore: prepare release vX.Y.Z`. Tag: `git tag vX.Y.Z`.
6. Push and tag only when ready; create the GitHub release with the zip and `.sha256`.
7. Prepare SourceForge files: `./scripts/prepare-sourceforge-release.sh X.Y.Z` (see [sourceforge.md](sourceforge.md)).

## Signing

Default is ad-hoc. For a Developer ID build: `CODESIGN_IDENTITY="Developer ID Application: ..." ./scripts/package-app.sh`. Notarization is not scripted yet.
