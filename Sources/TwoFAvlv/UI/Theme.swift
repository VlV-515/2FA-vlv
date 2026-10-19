import AppKit
import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// Color that adapts to light/dark appearance.
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let hex = isDark ? dark : light
            return NSColor(
                srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}

/// Semantic tokens. Slate surfaces, green accent (matches the app icon), contrast >= 4.5:1.
enum Theme {
    static let accent = Color.adaptive(light: 0x15803D, dark: 0x4ADE80)
    static let warning = Color.adaptive(light: 0xB45309, dark: 0xFBBF24)
    static let danger = Color.adaptive(light: 0xB91C1C, dark: 0xF87171)
    static let surface = Color.adaptive(light: 0xF1F5F9, dark: 0x1E293B)
    static let background = Color.adaptive(light: 0xFFFFFF, dark: 0x0F172A)
    static let border = Color.adaptive(light: 0xCBD5E1, dark: 0x334155)
    static let textSecondary = Color.adaptive(light: 0x475569, dark: 0x94A3B8)

    static let spacing: CGFloat = 8
    static let radius: CGFloat = 12
}

/// Letter badge with a brand-ish color per service.
struct BrandStyle {
    let background: Color
    let foreground: Color

    private static let known: [(keyword: String, color: UInt32, dark: Bool)] = [
        ("github", 0x24292F, false), ("google", 0x4285F4, false), ("amazon", 0xFF9900, true),
        ("discord", 0x5865F2, false), ("facebook", 0x1877F2, false), ("twitter", 0x14171A, false),
        ("twitch", 0x9146FF, false), ("stripe", 0x635BFF, false), ("heroku", 0x430098, false),
        ("epic", 0x2A2A2A, false), ("uber", 0x000000, false), ("lastpass", 0xD32D27, false),
        ("mercado", 0xFFE600, true), ("obsidian", 0x7C3AED, false), ("auth0", 0xEB5424, false),
        ("activision", 0x1D1D1B, false), ("private internet", 0x2F9E44, false),
        ("volabit", 0x0F766E, false), ("microsoft", 0x2563EB, false), ("apple", 0x1D1D1F, false),
        ("dropbox", 0x0061FF, false), ("steam", 0x1B2838, false), ("paypal", 0x003087, false)
    ]

    static func make(for title: String) -> BrandStyle {
        let lower = title.lowercased()
        if let match = known.first(where: { lower.contains($0.keyword) }) {
            return BrandStyle(background: Color(hex: match.color), foreground: match.dark ? Color(hex: 0x111111) : .white)
        }
        // Stable hue from the name (String.hashValue is randomized per launch).
        let seed = lower.unicodeScalars.reduce(UInt32(5381)) { ($0 &* 33) &+ $1.value }
        let hue = Double(seed % 360) / 360
        return BrandStyle(background: Color(hue: hue, saturation: 0.55, brightness: 0.52), foreground: .white)
    }
}
