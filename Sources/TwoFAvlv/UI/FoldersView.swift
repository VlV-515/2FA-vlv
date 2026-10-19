import SwiftUI
import TwoFACore

struct FoldersView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var store: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var newName = ""

    private var t: AppCopy { settings.copy }

    var body: some View {
        VStack(spacing: 0) {
            Text(t.foldersTitle).font(.headline).padding(.top, 16)

            if store.folders.isEmpty {
                Text(t.noFolders)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                List {
                    ForEach(store.folders) { folder in
                        FolderRow(folder: folder)
                    }
                    .onMove { store.moveFolder(from: $0, to: $1) }
                }
                .frame(height: min(CGFloat(store.folders.count) * 40 + 16, 260))
            }

            HStack {
                TextField(t.newFolder, text: $newName, prompt: Text(t.newFolderPlaceholder))
                    .onSubmit(add)
                Button(t.add, action: add)
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            HStack {
                Spacer()
                Button(t.done) { dismiss() }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
            }
            .padding(20)
        }
        .frame(width: 380)
    }

    private func add() {
        if store.addFolder(named: newName) != nil { newName = "" }
    }
}

private struct FolderRow: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var store: AccountStore
    let folder: Folder
    @State private var text: String

    init(folder: Folder) {
        self.folder = folder
        _text = State(initialValue: folder.name)
    }

    var body: some View {
        HStack {
            Image(systemName: "folder.fill").foregroundStyle(Theme.accent).accessibilityHidden(true)
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .onSubmit(commit)
                .onDisappear(perform: commit)
                .accessibilityLabel(settings.copy.foldersTitle)
            Spacer()
            Button(role: .destructive) { store.deleteFolder(folder.id) } label: { Image(systemName: "trash") }
                .buttonStyle(.borderless)
                .help(settings.copy.delete)
                .accessibilityLabel(settings.copy.delete)
        }
        .padding(.vertical, 4)
    }

    private func commit() {
        store.renameFolder(folder.id, to: text)
    }
}
