import Foundation

public struct AccountSection: Identifiable, Equatable {
    public enum Kind: Equatable {
        case favorites
        case folder(UUID)
        case unfiled
    }

    public let kind: Kind
    public var accounts: [Account]

    public var id: String {
        switch kind {
        case .favorites: return "favorites"
        case .folder(let id): return id.uuidString
        case .unfiled: return "unfiled"
        }
    }
}

public struct ImportSummary: Equatable {
    public var added: Int
    public var duplicates: Int
    public var skipped: Int
}

/// Accounts + folders, persisted as JSON. Secrets go to `secretStore` when `useSecretStore` is true.
public final class AccountStore: ObservableObject {
    private struct VaultFile: Codable {
        var version: Int
        var accounts: [Record]
        var folders: [Folder]
    }

    private struct Record: Codable {
        var account: Account
        var inlineSecret: String?

        enum CodingKeys: String, CodingKey { case account, inlineSecret }
    }

    @Published public private(set) var accounts: [Account] = []
    @Published public private(set) var folders: [Folder] = []
    /// Set when the last persist could not use the secret store and fell back to the file.
    @Published public private(set) var secretStoreError: String?

    private let fileURL: URL
    private let secretStore: SecretStoring
    public var useSecretStore: Bool

    public init(fileURL: URL, secretStore: SecretStoring, useSecretStore: Bool) {
        self.fileURL = fileURL
        self.secretStore = secretStore
        self.useSecretStore = useSecretStore
    }

    public static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("2FA-vlv", isDirectory: true).appendingPathComponent("vault.json")
    }

    // MARK: Persistence

    public func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let file = try? JSONDecoder().decode(VaultFile.self, from: data) else {
            accounts = []
            folders = []
            return
        }
        let stored: [UUID: String]
        do { stored = try secretStore.load() } catch {
            stored = [:]
            secretStoreError = String(describing: error)
        }
        accounts = file.accounts.map { record in
            var account = record.account
            account.secret = record.inlineSecret ?? stored[account.id] ?? ""
            return account
        }
        folders = file.folders
    }

    /// Switch where secrets are kept and rewrite everything.
    public func setUseSecretStore(_ value: Bool) {
        useSecretStore = value
        persist()
    }

    private func persist() {
        secretStoreError = nil
        var inline = !useSecretStore
        if useSecretStore {
            do {
                try secretStore.save(Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0.secret) }))
            } catch {
                inline = true
                secretStoreError = String(describing: error)
            }
        } else {
            try? secretStore.delete()
        }

        let records = accounts.map { account -> Record in
            var clean = account
            clean.secret = ""
            return Record(account: clean, inlineSecret: inline ? account.secret : nil)
        }
        let file = VaultFile(version: 1, accounts: records, folders: folders)
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(file).write(to: fileURL, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
        } catch {
            secretStoreError = "Could not write vault: \(error.localizedDescription)"
        }
    }

    // MARK: Mutations

    public func add(_ account: Account) {
        accounts.append(account)
        persist()
    }

    public func update(_ account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[index] = account
        persist()
    }

    public func delete(_ id: UUID) {
        accounts.removeAll { $0.id == id }
        persist()
    }

    public func toggleFavorite(_ id: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].isFavorite.toggle()
        persist()
    }

    public func setFolder(_ folderID: UUID?, for id: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].folderID = folderID
        persist()
    }

    /// Advance an HOTP counter after its code was used.
    public func incrementCounter(_ id: UUID) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].counter += 1
        persist()
    }

    @discardableResult
    public func addFolder(named name: String) -> Folder? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let folder = Folder(name: trimmed)
        folders.append(folder)
        persist()
        return folder
    }

    public func renameFolder(_ id: UUID, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let index = folders.firstIndex(where: { $0.id == id }) else { return }
        folders[index].name = trimmed
        persist()
    }

    /// Accounts in the folder become unfiled.
    public func deleteFolder(_ id: UUID) {
        folders.removeAll { $0.id == id }
        for index in accounts.indices where accounts[index].folderID == id {
            accounts[index].folderID = nil
        }
        persist()
    }

    /// Reorder inside one section. `offsets`/`destination` follow SwiftUI `onMove` semantics
    /// relative to the section's own list.
    public func move(in sectionID: String, from offsets: IndexSet, to destination: Int) {
        guard let section = sections(query: "").first(where: { $0.id == sectionID }) else { return }
        var ids = section.accounts.map(\.id)
        let moving = offsets.sorted().map { ids[$0] }
        let insertAt = destination - offsets.filter { $0 < destination }.count
        for index in offsets.sorted(by: >) { ids.remove(at: index) }
        ids.insert(contentsOf: moving, at: min(max(insertAt, 0), ids.count))

        let sectionSet = Set(ids)
        var queue = ids.makeIterator()
        let lookup = Dictionary(uniqueKeysWithValues: accounts.map { ($0.id, $0) })
        accounts = accounts.map { account in
            sectionSet.contains(account.id) ? lookup[queue.next()!]! : account
        }
        persist()
    }

    public func moveFolder(from offsets: IndexSet, to destination: Int) {
        let moving = offsets.sorted().map { folders[$0] }
        let insertAt = destination - offsets.filter { $0 < destination }.count
        for index in offsets.sorted(by: >) { folders.remove(at: index) }
        folders.insert(contentsOf: moving, at: min(max(insertAt, 0), folders.count))
        persist()
    }

    // MARK: Import

    /// Merge accounts, skipping duplicates. New folders are matched by name.
    @discardableResult
    public func merge(_ result: LastPassImporter.Result) -> ImportSummary {
        var folderRemap: [UUID: UUID] = [:]
        for folder in result.folders {
            if let existing = folders.first(where: { $0.name.lowercased() == folder.name.lowercased() }) {
                folderRemap[folder.id] = existing.id
            } else {
                folders.append(folder)
                folderRemap[folder.id] = folder.id
            }
        }
        var added = 0
        var duplicates = 0
        for var account in result.accounts {
            if accounts.contains(where: { $0.isDuplicate(of: account) }) {
                duplicates += 1
                continue
            }
            account.folderID = account.folderID.flatMap { folderRemap[$0] }
            accounts.append(account)
            added += 1
        }
        persist()
        return ImportSummary(added: added, duplicates: duplicates, skipped: result.skipped)
    }

    /// Add a single account unless it already exists. Returns false on duplicate.
    @discardableResult
    public func addIfNew(_ account: Account) -> Bool {
        guard !accounts.contains(where: { $0.isDuplicate(of: account) }) else { return false }
        add(account)
        return true
    }

    // MARK: Queries

    public func sections(query: String) -> [AccountSection] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        let matches = accounts.filter { account in
            needle.isEmpty
                || account.issuer.lowercased().contains(needle)
                || account.name.lowercased().contains(needle)
        }

        var result: [AccountSection] = []
        let favorites = matches.filter(\.isFavorite)
        if !favorites.isEmpty { result.append(AccountSection(kind: .favorites, accounts: favorites)) }

        for folder in folders {
            let inFolder = matches.filter { !$0.isFavorite && $0.folderID == folder.id }
            if !inFolder.isEmpty || needle.isEmpty {
                result.append(AccountSection(kind: .folder(folder.id), accounts: inFolder))
            }
        }

        let folderIDs = Set(folders.map(\.id))
        let unfiled = matches.filter { !$0.isFavorite && ($0.folderID == nil || !folderIDs.contains($0.folderID!)) }
        if !unfiled.isEmpty { result.append(AccountSection(kind: .unfiled, accounts: unfiled)) }
        return result
    }

    public func folderName(_ id: UUID) -> String? {
        folders.first { $0.id == id }?.name
    }
}
