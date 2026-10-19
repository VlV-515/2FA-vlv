import SwiftUI
import TwoFACore

struct AccountListView: View {
    @EnvironmentObject private var state: AppState
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var store: AccountStore
    let compact: Bool

    @State private var query = ""
    @State private var deleteTarget: Account?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .confirmationDialog(
            settings.copy.deleteTitle,
            isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } }),
            titleVisibility: .visible
        ) {
            Button(settings.copy.delete, role: .destructive) {
                if let target = deleteTarget { store.delete(target.id) }
                deleteTarget = nil
            }
            Button(settings.copy.cancel, role: .cancel) { deleteTarget = nil }
        } message: {
            Text(settings.copy.deleteMessage)
        }
    }

    private var header: some View {
        HStack(spacing: Theme.spacing) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.textSecondary)
                TextField(settings.copy.searchPlaceholder, text: $query)
                    .textFieldStyle(.plain)
                    .accessibilityLabel(settings.copy.searchPlaceholder)
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .buttonStyle(.plain)
                        .foregroundStyle(Theme.textSecondary)
                        .accessibilityLabel(settings.copy.cancel)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Theme.surface))

            if compact {
                Button { state.showMainWindow() } label: { Image(systemName: "macwindow") }
                    .help(settings.copy.showApp)
                    .accessibilityLabel(settings.copy.showApp)
                Button { state.lock.lock() } label: { Image(systemName: "lock") }
                    .help(settings.copy.lockNow)
                    .disabled(!settings.lockEnabled)
                    .accessibilityLabel(settings.copy.lockNow)
            } else {
                Menu {
                    Button(settings.copy.addAccountMenu) { state.requestAdd() }
                    Button(settings.copy.importLastPass) { state.importLastPass() }
                    Divider()
                    Button(settings.copy.manageFolders) { state.requestFolders() }
                } label: {
                    Image(systemName: "plus")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help(settings.copy.add)
                .accessibilityLabel(settings.copy.add)
            }
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var content: some View {
        let sections = store.sections(query: query)
        if store.accounts.isEmpty {
            emptyState
        } else if sections.isEmpty {
            placeholder(icon: "magnifyingglass", title: settings.copy.noResults, message: nil)
        } else {
            List {
                ForEach(sections) { section in
                    Section {
                        if section.accounts.isEmpty {
                            Text(settings.copy.emptyFolder)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        ForEach(section.accounts) { account in
                            AccountRowView(
                                account: account,
                                onEdit: { state.showMainWindow(); state.editorRequest = .edit(account) },
                                onDelete: { deleteTarget = account }
                            )
                        }
                        .onMove(perform: query.isEmpty ? { offsets, destination in
                            store.move(in: section.id, from: offsets, to: destination)
                        } : nil)
                    } header: {
                        sectionHeader(section)
                    }
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
    }

    private func sectionHeader(_ section: AccountSection) -> some View {
        let t = settings.copy
        let (icon, title): (String, String) = {
            switch section.kind {
            case .favorites: return ("star.fill", t.favorites)
            case .folder(let id): return ("folder.fill", store.folderName(id) ?? "")
            case .unfiled: return ("tray.full", t.otherAccounts)
            }
        }()
        return Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.textSecondary)
            .textCase(nil)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "key.viewfinder")
                .font(.system(size: 42))
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)
            Text(settings.copy.emptyTitle).font(.headline)
            Text(settings.copy.emptyMessage)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            HStack {
                Button(settings.copy.addAccountMenu) { state.requestAdd() }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                Button(settings.copy.importLastPass) { state.importLastPass() }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func placeholder(icon: String, title: String, message: String?) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 28)).foregroundStyle(Theme.textSecondary)
            Text(title).foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
