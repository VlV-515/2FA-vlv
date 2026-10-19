import AppKit

enum ClipboardService {
    /// Marker honored by clipboard managers (including paste-vlv) to skip history capture.
    private static let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
    private static var clearTask: Task<Void, Never>?

    @MainActor
    static func copy(_ text: String, clearAfter seconds: Int?) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.declareTypes([.string, concealedType], owner: nil)
        pasteboard.setString(text, forType: .string)
        pasteboard.setData(Data(), forType: concealedType)
        let stamp = pasteboard.changeCount

        clearTask?.cancel()
        guard let seconds else { return }
        clearTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
            guard !Task.isCancelled, NSPasteboard.general.changeCount == stamp else { return }
            NSPasteboard.general.clearContents()
        }
    }
}
