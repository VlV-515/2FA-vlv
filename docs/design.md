# Design

Chosen with the `ui-ux-pro-max` skill (query: authenticator, security tool, dark minimal) on a native SwiftUI stack.

## Direction

- Style: dark-first, minimal, high contrast; also fully supports light mode.
- Slate surfaces, green accent ("run green", signals valid/safe) with amber and red for the expiring countdown.
- Typography: system font (SF Pro). Codes use rounded semibold with monospaced digits so they never shift.

## Tokens (`UI/Theme.swift`)

| Token | Light | Dark |
| --- | --- | --- |
| background | `#FFFFFF` | `#0F172A` |
| surface | `#F1F5F9` | `#1E293B` |
| border | `#CBD5E1` | `#334155` |
| accent | `#15803D` | `#4ADE80` |
| warning | `#B45309` | `#FBBF24` |
| danger | `#B91C1C` | `#F87171` |
| text secondary | `#475569` | `#94A3B8` |

Spacing uses a 4/8 pt rhythm. Corner radius 12 for cards, 8 for fields.

## Accessibility

- Contrast targets 4.5:1 for text in both appearances.
- Countdown meaning is never color-only: the ring contains the number of seconds.
- Icon-only controls have help text and accessibility labels. Rows are single VoiceOver elements that read service, account and code.
- No decorative animation. Toast fades in 200 ms.

## Logo

A slate rounded tile, a green 75% countdown ring (time) around a white shield with a keyhole (security). Generated reproducibly by `scripts/make-icon.swift`; `scripts/make-icns.sh` builds the `.iconset`, `AppIcon.icns` and `docs/images/app-icon.png`. The menu bar icon is a template ring-and-dot drawn in code (`AppBranding.makeMenuBarIcon`).
