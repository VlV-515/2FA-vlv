import AppKit
import SwiftUI
import TwoFACore
import UniformTypeIdentifiers

enum EditorRequest: Identifiable {
    case add
    case edit(Account)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let account): return account.id.uuidString
        }
    }
}

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

/// Shared by the main window, menu bar popover and settings.
@MainActor
final class AppState: ObservableObject {
    let settings: AppSettings
    let store: AccountStore
    let lock: LockManager

    @Published var toast: String?
    @Published var editorRequest: EditorRequest?
    @Published var showFolders = false
    @Published var alert: AppAlert?

    /// Wired by the app delegate.
    var openSettings: () -> Void = {}
    var openAbout: () -> Void = {}
    var showMainWindow: () -> Void = {}

    private var toastTask: Task<Void, Never>?

    init(settings: AppSettings) {
        self.settings = settings
        self.store = AccountStore(
            fileURL: AccountStore.defaultFileURL(),
            secretStore: KeychainSecretStore(),
            useSecretStore: settings.useKeychain
        )
        self.lock = LockManager(settings: settings)
        store.load()
        if store.secretStoreError != nil, settings.useKeychain {
            alert = AppAlert(title: settings.copy.security, message: settings.copy.keychainFallback)
        }
    }

    var copy: AppCopy { settings.copy }

    func showToast(_ text: String) {
        toast = text
        toastTask?.cancel()
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            guard !Task.isCancelled else { return }
            self?.toast = nil
        }
    }

    func copyCode(for account: Account) {
        guard let code = OTP.code(for: account) else { return }
        ClipboardService.copy(code, clearAfter: settings.clearClipboard ? settings.clearClipboardSeconds : nil)
        showToast(copy.copied)
    }

    func requestAdd() {
        showMainWindow()
        editorRequest = .add
    }

    func requestFolders() {
        showMainWindow()
        showFolders = true
    }

    func applyKeychainSetting() {
        store.setUseSecretStore(settings.useKeychain)
        if settings.useKeychain, store.secretStoreError != nil {
            alert = AppAlert(title: copy.security, message: copy.keychainFallback)
        }
    }

    func importLastPass() {
        showMainWindow()
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.message = copy.importPanelMessage
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let result = try LastPassImporter.parse(try Data(contentsOf: url))
            let summary = store.merge(result)
            alert = AppAlert(
                title: copy.importTitle,
                message: copy.importSummary(added: summary.added, duplicates: summary.duplicates, skipped: summary.skipped)
            )
        } catch {
            alert = AppAlert(title: copy.importTitle, message: copy.importFailed)
        }
    }
}
