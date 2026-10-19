# SourceForge Mirror

SourceForge is a secondary mirror for 2FA-vlv release files. GitHub Releases remain the primary source.

- Public project: <https://sourceforge.net/projects/2fa-vlv/>
- Release folder after upload: <https://sourceforge.net/projects/2fa-vlv/files/v1.0.0/>
- Username: `vlv`

> The SourceForge project is not registered yet. Register it with the unix name `2fa-vlv`; that value is the `PROJECTNAME` in file paths.

## Prepare local files

```sh
./scripts/prepare-sourceforge-release.sh 1.0.0
```

Creates (the `dist/` folder is gitignored):

```text
dist/sourceforge/v1.0.0/2FA-vlv-1.0.0-macos-unsigned.zip
dist/sourceforge/v1.0.0/2FA-vlv-1.0.0-macos-unsigned.zip.sha256
dist/sourceforge/v1.0.0/readme.md
```

`readme.md` appears as release notes in the SourceForge file browser.

## Upload with the web UI

1. Open the project, go to Files, add folder `v1.0.0`.
2. Upload the three files above.
3. Mark the ZIP as the default macOS download if asked.

## Upload with SSH

```sh
./scripts/publish-sourceforge.sh
```

Uploads to `/home/frs/project/2fa-vlv/v1.0.0/` (override with `VERSION=x.y.z`). Direct download:

```text
https://sourceforge.net/projects/2fa-vlv/files/v1.0.0/2FA-vlv-1.0.0-macos-unsigned.zip/download
```

## SSH key setup

```sh
ssh-keygen -t ed25519 -C "vlv for sourceforge" -f ~/.ssh/id_ed25519_sourceforge
cat ~/.ssh/id_ed25519_sourceforge.pub
```

Add the public key in the SourceForge account settings, then verify:

```sh
ssh vlv@frs.sourceforge.net true
```

The ED25519 fingerprint of `frs.sourceforge.net` is `SHA256:209BDmH3jsRyO9UeGPPgLWPSegKmYCBIya0nR/AWWCY`.

## Signing status

Builds are ad-hoc signed, not notarized. SourceForge does not change Gatekeeper behavior.
