# Usage

## Read and copy codes

Each row shows the service, the account, the current code and a countdown ring. The ring turns amber under 10 s and red under 5 s (the number inside always shows the seconds). **Click a row** to copy the code.

## Add an account

**+ → Add Account...** (or `⌘N`). Three ways:

- **Manual.** Service, account and the Base32 secret key. *Advanced* has type (TOTP, HOTP, Steam), algorithm, digits and period/counter.
- **Link.** Paste an `otpauth://` link. The form fills in for review.
- **QR code.** Choose an image file, or *Capture Screen Area* and drag over the QR on your screen.

## Import from LastPass Authenticator

**+ → Import LastPass Backup...** (or `⌘I`) and pick the JSON backup. You get a summary: added, already present, skipped. Folders and favorites are kept. Re-importing is safe: duplicates are skipped.

## Organize

- **Favorites:** right-click → *Add to Favorites*. They appear first.
- **Folders:** **+ → Manage Folders...** to create, rename, reorder and delete. Right-click an account → *Move to Folder*. Deleting a folder keeps its accounts.
- **Order:** drag rows inside their section. Reordering is off while searching.
- **Search:** type in the search box; matches service and account name.

## HOTP accounts

Counter-based accounts show a refresh button instead of the ring. Press it for the next code. Copying does not advance the counter.

## Menu bar and shortcut

With the menu bar icon on, click it for a quick popover, right-click for the menu. Optional global shortcut `⌃⌥⌘2` shows or hides the window.

## Lock

`⌘L` locks the app (when the lock is enabled in Settings → Security). It also locks on inactivity and when the Mac sleeps.

## Keyboard

| Shortcut | Action |
| --- | --- |
| `⌘N` | Add account |
| `⌘I` | Import LastPass backup |
| `⌘L` | Lock |
| `⌘,` | Settings |
| `⌘W` / `⌘Q` | Close window / quit |
