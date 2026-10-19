import AppKit
import SwiftUI
import TwoFACore

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let t = settings.copy
        TabView {
            GeneralSettings()
                .tabItem { Label(t.general, systemImage: "gearshape") }
            SecuritySettings()
                .tabItem { Label(t.security, systemImage: "lock.shield") }
            DataSettings()
                .tabItem { Label(t.data, systemImage: "externaldrive") }
            AboutView()
                .tabItem { Label(t.aboutTab, systemImage: "info.circle") }
        }
        .frame(width: 520, height: 430)
    }
}

private struct GeneralSettings: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        let t = settings.copy
        Form {
            Section(t.languageLabel) {
                Picker(t.languageLabel, selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text("\(language.flag)  \(language.pickerTitle)").tag(language)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            Section(t.appearanceSection) {
                Toggle(t.hideCodes, isOn: $settings.hideCodes)
                Text(t.hideCodesHelp).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Section(t.systemSection) {
                Toggle(t.showMenuBarIcon, isOn: $settings.showMenuBarIcon)
                Toggle(t.globalHotKey, isOn: $settings.globalHotKey)
                Toggle(t.launchAtLogin, isOn: Binding(
                    get: { launchAtLogin },
                    set: { newValue in
                        if LaunchAtLogin.set(newValue) {
                            launchAtLogin = newValue
                        } else {
                            launchAtLogin = LaunchAtLogin.isEnabled
                            state.alert = AppAlert(title: t.systemSection, message: t.launchAtLoginFailed)
                        }
                    }
                ))
            }
        }
        .formStyle(.grouped)
    }
}

private struct SecuritySettings: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let t = settings.copy
        Form {
            Section {
                Toggle(t.useKeychain, isOn: $settings.useKeychain)
                    .onChange(of: settings.useKeychain) { _ in state.applyKeychainSetting() }
                Text(t.useKeychainHelp).font(.caption).foregroundStyle(Theme.textSecondary)
            }
            Section {
                Toggle(t.requireAuth, isOn: $settings.lockEnabled)
                    .onChange(of: settings.lockEnabled) { _ in state.lock.settingChanged() }
                Picker(t.autoLock, selection: $settings.autoLockMinutes) {
                    Text(t.never).tag(0)
                    ForEach([1, 2, 5, 10, 15, 30], id: \.self) { Text(t.minutes($0)).tag($0) }
                }
                .disabled(!settings.lockEnabled)
            }
            Section {
                Toggle(t.clearClipboard, isOn: $settings.clearClipboard)
                Picker(t.clearAfter, selection: $settings.clearClipboardSeconds) {
                    ForEach([10, 20, 30, 60], id: \.self) { Text(t.seconds($0)).tag($0) }
                }
                .disabled(!settings.clearClipboard)
            }
        }
        .formStyle(.grouped)
    }
}

private struct DataSettings: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        let t = settings.copy
        Form {
            Section(t.importSection) {
                Text(t.importHelp).font(.caption).foregroundStyle(Theme.textSecondary)
                Button(t.importLastPass) { state.importLastPass() }
            }
            Section(t.vaultSection) {
                Text(AccountStore.defaultFileURL().path)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .textSelection(.enabled)
                Button(t.revealVault) {
                    NSWorkspace.shared.activateFileViewerSelecting([AccountStore.defaultFileURL()])
                }
            }
        }
        .formStyle(.grouped)
    }
}
