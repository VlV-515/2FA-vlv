import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = AppSettings()
    private lazy var state = AppState(settings: settings)
    private lazy var hotKey = HotKeyManager { [weak self] in self?.toggleMainWindow() }

    private var mainWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        state.openSettings = { [weak self] in self?.showSettings() }
        state.openAbout = { [weak self] in self?.showAbout() }
        state.showMainWindow = { [weak self] in self?.showMainWindow() }

        buildMainMenu()
        showMainWindow()
        applyMenuBarIcon()
        applyHotKey()

        settings.$language.dropFirst().sink { [weak self] _ in
            self?.buildMainMenu()
            self?.applyWindowTitles()
        }.store(in: &cancellables)
        settings.$showMenuBarIcon.dropFirst().sink { [weak self] _ in self?.applyMenuBarIcon() }.store(in: &cancellables)
        settings.$globalHotKey.dropFirst().sink { [weak self] _ in self?.applyHotKey() }.store(in: &cancellables)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { showMainWindow() }
        return true
    }

    // MARK: Windows

    private func host<Content: View>(_ view: Content) -> NSHostingController<some View> {
        NSHostingController(rootView: view
            .environmentObject(state)
            .environmentObject(settings)
            .environmentObject(state.store)
            .environmentObject(state.lock))
    }

    func showMainWindow() {
        if mainWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 640),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = host(RootView(compact: false))
            window.isReleasedWhenClosed = false
            window.setFrameAutosaveName("MainWindow")
            if !window.setFrameUsingName("MainWindow") { window.center() }
            mainWindow = window
        }
        applyWindowTitles()
        popover?.performClose(nil)
        NSApp.activate(ignoringOtherApps: true)
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    private func toggleMainWindow() {
        if let window = mainWindow, window.isVisible, NSApp.isActive {
            window.orderOut(nil)
            NSApp.hide(nil)
        } else {
            showMainWindow()
        }
    }

    private func showSettings() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 430),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = host(SettingsView())
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }
        applyWindowTitles()
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    private func showAbout() {
        if aboutWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 340, height: 460),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = host(AboutView())
            window.isReleasedWhenClosed = false
            window.center()
            aboutWindow = window
        }
        applyWindowTitles()
        NSApp.activate(ignoringOtherApps: true)
        aboutWindow?.makeKeyAndOrderFront(nil)
    }

    private func applyWindowTitles() {
        let t = settings.copy
        mainWindow?.title = AppBranding.displayName
        settingsWindow?.title = t.settings
        aboutWindow?.title = t.about
    }

    // MARK: Menu bar

    private func applyMenuBarIcon() {
        if settings.showMenuBarIcon {
            guard statusItem == nil else { return }
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            item.button?.image = AppBranding.makeMenuBarIcon()
            item.button?.toolTip = AppBranding.displayName
            item.button?.target = self
            item.button?.action = #selector(statusItemClicked(_:))
            item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
            statusItem = item

            let popover = NSPopover()
            popover.behavior = .transient
            popover.contentSize = NSSize(width: 340, height: 460)
            popover.contentViewController = host(RootView(compact: true))
            self.popover = popover
        } else if let item = statusItem {
            popover?.performClose(nil)
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
            popover = nil
        }
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            let t = settings.copy
            let menu = NSMenu()
            menu.addItem(item(t.showApp, #selector(showMainAction)))
            menu.addItem(item(t.lockNow, #selector(lockAction)))
            menu.addItem(.separator())
            menu.addItem(item(t.preferences, #selector(showSettingsAction)))
            menu.addItem(item(t.about, #selector(showAboutAction)))
            menu.addItem(.separator())
            menu.addItem(item(t.quit, #selector(NSApplication.terminate(_:)), target: NSApp))
            statusItem?.menu = menu
            sender.performClick(nil)
            statusItem?.menu = nil
        } else if let popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    private func applyHotKey() {
        if settings.globalHotKey { hotKey.register() } else { hotKey.unregister() }
    }

    // MARK: Main menu

    private func item(_ title: String, _ action: Selector?, key: String = "", modifiers: NSEvent.ModifierFlags = .command, target: AnyObject? = nil) -> NSMenuItem {
        let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
        menuItem.keyEquivalentModifierMask = modifiers
        menuItem.target = target ?? self
        return menuItem
    }

    private func buildMainMenu() {
        let t = settings.copy
        let main = NSMenu()

        let appMenu = NSMenu()
        appMenu.addItem(item(t.about, #selector(showAboutAction)))
        appMenu.addItem(.separator())
        appMenu.addItem(item(t.preferences, #selector(showSettingsAction), key: ","))
        appMenu.addItem(.separator())
        appMenu.addItem(item(t.hideApp, #selector(NSApplication.hide(_:)), key: "h", target: NSApp))
        appMenu.addItem(.separator())
        appMenu.addItem(item(t.quit, #selector(NSApplication.terminate(_:)), key: "q", target: NSApp))
        let appItem = NSMenuItem(); appItem.submenu = appMenu
        main.addItem(appItem)

        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(item(t.addAccountMenu, #selector(addAccountAction), key: "n"))
        fileMenu.addItem(item(t.importLastPassMenu, #selector(importAction), key: "i"))
        fileMenu.addItem(item(t.manageFolders, #selector(foldersAction)))
        fileMenu.addItem(.separator())
        fileMenu.addItem(item(t.lockNow, #selector(lockAction), key: "l"))
        let fileItem = NSMenuItem(); fileItem.submenu = fileMenu
        main.addItem(fileItem)

        let editMenu = NSMenu(title: t.edit)
        editMenu.addItem(item("Undo", Selector(("undo:")), key: "z", target: nil))
        editMenu.addItem(item("Redo", Selector(("redo:")), key: "Z", target: nil))
        editMenu.addItem(.separator())
        editMenu.addItem(item("Cut", #selector(NSText.cut(_:)), key: "x", target: nil))
        editMenu.addItem(item("Copy", #selector(NSText.copy(_:)), key: "c", target: nil))
        editMenu.addItem(item("Paste", #selector(NSText.paste(_:)), key: "v", target: nil))
        editMenu.addItem(item("Select All", #selector(NSText.selectAll(_:)), key: "a", target: nil))
        let editItem = NSMenuItem(); editItem.submenu = editMenu
        main.addItem(editItem)

        let windowMenu = NSMenu(title: t.window)
        windowMenu.addItem(item("Minimize", #selector(NSWindow.performMiniaturize(_:)), key: "m", target: nil))
        windowMenu.addItem(item("Close", #selector(NSWindow.performClose(_:)), key: "w", target: nil))
        let windowItem = NSMenuItem(); windowItem.submenu = windowMenu
        main.addItem(windowItem)

        NSApp.mainMenu = main
        NSApp.windowsMenu = windowMenu
    }

    @objc private func showAboutAction() { showAbout() }
    @objc private func showSettingsAction() { showSettings() }
    @objc private func showMainAction() { showMainWindow() }
    @objc private func lockAction() { state.lock.lock() }
    @objc private func addAccountAction() { state.requestAdd() }
    @objc private func importAction() { state.importLastPass() }
    @objc private func foldersAction() { state.requestFolders() }
}
