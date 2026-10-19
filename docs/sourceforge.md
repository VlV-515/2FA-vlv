# SourceForge

Project page: <https://sourceforge.net/projects/2fa-vlv/>

> Note: the SourceForge project is not registered yet. The link is used as if it were. Register the project with the unix name `2fa-vlv` so the link in the app and README works.

## Publishing a release (when registered)

1. Build the zip: `./scripts/package-release.sh X.Y.Z`.
2. Upload `dist/2FA-vlv-X.Y.Z-macos-unsigned.zip` and its `.sha256` to `Files/X.Y.Z/` (web UI or `rsync -e ssh dist/*.zip USER@frs.sourceforge.net:/home/frs/project/2fa-vlv/X.Y.Z/`).
3. Mark the zip as the default download for macOS in the file's info panel.
4. Paste the release notes from `.github/release-notes/vX.Y.Z.md`.
