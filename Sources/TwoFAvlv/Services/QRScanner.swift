import AppKit
import CoreImage

enum QRScanner {
    /// Every QR payload found in the image.
    static func decode(_ image: NSImage) -> [String] {
        guard let tiff = image.tiffRepresentation, let ciImage = CIImage(data: tiff) else { return [] }
        return decode(ciImage)
    }

    static func decode(fileAt url: URL) -> [String] {
        guard let ciImage = CIImage(contentsOf: url) else { return [] }
        return decode(ciImage)
    }

    private static func decode(_ ciImage: CIImage) -> [String] {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) ?? []
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }
    }

    /// Lets the user drag-select a screen region (system crosshair). Nil when cancelled.
    static func captureScreenRegion() async -> [String]? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("2fa-vlv-\(UUID().uuidString).png")
        defer { try? FileManager.default.removeItem(at: url) }

        let ran = await Task.detached { () -> Bool in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = ["-i", "-x", url.path]
            do {
                try process.run()
                process.waitUntilExit()
                return true
            } catch {
                return false
            }
        }.value

        guard ran, FileManager.default.fileExists(atPath: url.path) else { return nil }
        return decode(fileAt: url)
    }
}
