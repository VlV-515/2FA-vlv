import AppKit
import LocalAuthentication

/// Gate in front of the codes: Touch ID, Apple Watch or login password.
@MainActor
final class LockManager: ObservableObject {
    @Published private(set) var isLocked = false
    @Published private(set) var failed = false

    private let settings: AppSettings
    private var lastActivity = Date()
    private var timer: Timer?
    private var eventMonitor: Any?
    private var authenticating = false

    init(settings: AppSettings) {
        self.settings = settings
        isLocked = settings.lockEnabled

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .mouseMoved, .scrollWheel]) { [weak self] event in
            self?.lastActivity = Date()
            return event
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkInactivity() }
        }
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.screensDidSleepNotification, NSWorkspace.willSleepNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.lock() }
            }
        }
    }

    func lock() {
        guard settings.lockEnabled else { return }
        isLocked = true
        failed = false
    }

    /// Called when the lock setting changes.
    func settingChanged() {
        if !settings.lockEnabled { isLocked = false }
        lastActivity = Date()
    }

    func unlock() {
        guard isLocked, !authenticating else { return }
        authenticating = true
        let context = LAContext()
        var error: NSError?
        let copy = settings.copy
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            // No credentials set up on this Mac: nothing to protect with, let the user in.
            authenticating = false
            isLocked = false
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: copy.unlockReason) { [weak self] success, _ in
            Task { @MainActor in
                guard let self else { return }
                self.authenticating = false
                self.failed = !success
                if success {
                    self.isLocked = false
                    self.lastActivity = Date()
                }
            }
        }
    }

    private func checkInactivity() {
        guard settings.lockEnabled, settings.autoLockMinutes > 0, !isLocked else { return }
        if Date().timeIntervalSince(lastActivity) >= Double(settings.autoLockMinutes * 60) {
            lock()
        }
    }
}
