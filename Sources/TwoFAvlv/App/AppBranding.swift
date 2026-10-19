import AppKit

enum AppBranding {
    static let displayName = "2FA-vlv"
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    static let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    static let developerURL = URL(string: "https://github.com/VlV-515")!
    static let projectURL = URL(string: "https://github.com/VlV-515/2fa-vlv")!
    static let releasesURL = URL(string: "https://github.com/VlV-515/2fa-vlv/releases")!
    static let sourceForgeURL = URL(string: "https://sourceforge.net/projects/2fa-vlv/")!
    static let licenseURL = URL(string: "https://github.com/VlV-515/2fa-vlv/blob/main/LICENSE")!

    static func makeAboutIcon() -> NSImage {
        if let url = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        let projectIcon = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Assets/AppIcon.icns")
        if let image = NSImage(contentsOf: projectIcon) {
            return image
        }
        return NSApp.applicationIconImage
    }

    /// Template image: open ring with a dot, reads as "timer + key".
    static func makeMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            NSColor.black.setStroke()
            let ring = NSBezierPath()
            ring.lineWidth = 1.8
            ring.lineCapStyle = .round
            ring.appendArc(withCenter: NSPoint(x: 9, y: 9), radius: 6.6, startAngle: 100, endAngle: 40, clockwise: false)
            ring.stroke()
            NSColor.black.setFill()
            NSBezierPath(ovalIn: NSRect(x: 6.6, y: 6.6, width: 4.8, height: 4.8)).fill()
            return true
        }
        image.isTemplate = true
        return image
    }
}
