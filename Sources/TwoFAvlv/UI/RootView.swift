import SwiftUI
import TwoFACore

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var lock: LockManager
    @EnvironmentObject private var settings: AppSettings
    let compact: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            if lock.isLocked {
                LockView()
            } else {
                AccountListView(compact: compact)
            }
            if let toast = state.toast, !lock.isLocked {
                Label(toast, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.surface))
                    .overlay(Capsule().stroke(Theme.border))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .animation(.easeOut(duration: 0.2), value: state.toast)
        .background(Theme.background)
        .frame(minWidth: compact ? 440 : 400, minHeight: compact ? 520 : 420)
        .sheet(item: $state.editorRequest) { request in
            AccountEditorView(request: request)
        }
        .sheet(isPresented: $state.showFolders) {
            FoldersView()
        }
        .alert(item: $state.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text(settings.copy.ok)))
        }
    }
}

struct LockView: View {
    @EnvironmentObject private var lock: LockManager
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)
            Text(settings.copy.lockedTitle).font(.headline)
            Button(settings.copy.unlock) { lock.unlock() }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .keyboardShortcut(.defaultAction)
            if lock.failed {
                Text(settings.copy.unlockFailed)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.danger)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { lock.unlock() }
    }
}
