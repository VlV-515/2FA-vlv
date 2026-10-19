import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish

    var id: String { rawValue }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇲🇽"
        }
    }

    var pickerTitle: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        }
    }
}

/// User preferences backed by UserDefaults. Every security-ish feature is opt-in/out here.
@MainActor
final class AppSettings: ObservableObject {
    private let defaults: UserDefaults

    @Published var language: AppLanguage { didSet { defaults.set(language.rawValue, forKey: Key.language) } }
    @Published var hideCodes: Bool { didSet { defaults.set(hideCodes, forKey: Key.hideCodes) } }
    @Published var useKeychain: Bool { didSet { defaults.set(useKeychain, forKey: Key.useKeychain) } }
    @Published var lockEnabled: Bool { didSet { defaults.set(lockEnabled, forKey: Key.lockEnabled) } }
    /// Minutes of inactivity before locking. 0 = never auto-lock.
    @Published var autoLockMinutes: Int { didSet { defaults.set(autoLockMinutes, forKey: Key.autoLockMinutes) } }
    @Published var clearClipboard: Bool { didSet { defaults.set(clearClipboard, forKey: Key.clearClipboard) } }
    @Published var clearClipboardSeconds: Int { didSet { defaults.set(clearClipboardSeconds, forKey: Key.clearClipboardSeconds) } }
    @Published var showMenuBarIcon: Bool { didSet { defaults.set(showMenuBarIcon, forKey: Key.showMenuBarIcon) } }
    @Published var globalHotKey: Bool { didSet { defaults.set(globalHotKey, forKey: Key.globalHotKey) } }

    private enum Key {
        static let language = "language"
        static let hideCodes = "hideCodes"
        static let useKeychain = "useKeychain"
        static let lockEnabled = "lockEnabled"
        static let autoLockMinutes = "autoLockMinutes"
        static let clearClipboard = "clearClipboard"
        static let clearClipboardSeconds = "clearClipboardSeconds"
        static let showMenuBarIcon = "showMenuBarIcon"
        static let globalHotKey = "globalHotKey"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        language = AppLanguage(rawValue: defaults.string(forKey: Key.language) ?? "") ?? .english
        hideCodes = defaults.object(forKey: Key.hideCodes) as? Bool ?? false
        useKeychain = defaults.object(forKey: Key.useKeychain) as? Bool ?? true
        lockEnabled = defaults.object(forKey: Key.lockEnabled) as? Bool ?? false
        autoLockMinutes = defaults.object(forKey: Key.autoLockMinutes) as? Int ?? 5
        clearClipboard = defaults.object(forKey: Key.clearClipboard) as? Bool ?? true
        clearClipboardSeconds = defaults.object(forKey: Key.clearClipboardSeconds) as? Int ?? 30
        showMenuBarIcon = defaults.object(forKey: Key.showMenuBarIcon) as? Bool ?? true
        globalHotKey = defaults.object(forKey: Key.globalHotKey) as? Bool ?? false
    }

    var copy: AppCopy { AppCopy(language: language) }
}
