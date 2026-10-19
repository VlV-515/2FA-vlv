# macOS native rules

- AppKit owns lifecycle, windows, menus, status item and popover. SwiftUI renders content inside `NSHostingController`.
- Share state through `AppState` (+ `AppSettings`, `AccountStore`, `LockManager`) injected as environment objects.
- Respect light and dark appearance: use `Theme` adaptive tokens, never raw hex in views.
- Use SF Symbols for UI icons. Letter badges for services. No emoji as icons (flags in the language picker are the one exception).
- Each icon-only button needs `.help` and `.accessibilityLabel`. Do not rely on color alone (ring shows seconds as a number).
- Digits use monospaced figures to avoid layout jump.
- Clipboard writes go through `ClipboardService` (concealed type + auto-clear).
- Keychain: one generic-password item, `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`. Fall back to the vault file with a visible warning if Keychain fails.
- Ad-hoc signing means Keychain/login-item prompts can reappear after updates. Document, do not hack around.
