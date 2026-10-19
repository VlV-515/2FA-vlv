import Foundation

/// Reads the JSON backup exported by LastPass Authenticator.
public enum LastPassImporter {
    public struct Result: Equatable {
        public var accounts: [Account]
        public var folders: [Folder]
        public var skipped: Int
    }

    public enum ImportError: Error, Equatable {
        case invalidFile
    }

    private struct Backup: Decodable {
        var accounts: [Entry]
        var folders: [FolderEntry]?
    }

    private struct Entry: Decodable {
        var issuerName: String?
        var originalIssuerName: String?
        var userName: String?
        var originalUserName: String?
        var secret: String?
        var algorithm: String?
        var digits: Int?
        var timeStep: Int?
        var isFavorite: Bool?
        var creationTimestamp: Double?
        var folderData: FolderData?
    }

    private struct FolderData: Decodable {
        var folderId: Int?
        var position: Int?
    }

    private struct FolderEntry: Decodable {
        var id: Int
        var name: String
    }

    /// LastPass folder 0 is the catch-all ("Otras cuentas") and folder 1 mirrors favorites.
    /// Neither becomes a real folder here.
    private static let builtInFolderIDs: Set<Int> = [0, 1]

    public static func parse(_ data: Data) throws -> Result {
        guard let backup = try? JSONDecoder().decode(Backup.self, from: data) else {
            throw ImportError.invalidFile
        }

        var folderMap: [Int: Folder] = [:]
        var folders: [Folder] = []
        for entry in backup.folders ?? [] where !builtInFolderIDs.contains(entry.id) {
            let folder = Folder(name: entry.name)
            folderMap[entry.id] = folder
            folders.append(folder)
        }

        let sorted = backup.accounts.enumerated().sorted { lhs, rhs in
            let l = lhs.element.folderData?.position ?? lhs.offset
            let r = rhs.element.folderData?.position ?? rhs.offset
            return l < r
        }

        var accounts: [Account] = []
        var skipped = 0
        for (_, entry) in sorted {
            guard let secret = entry.secret, Base32.isValid(secret) else {
                skipped += 1
                continue
            }
            let issuer = (entry.issuerName ?? entry.originalIssuerName ?? "").trimmingCharacters(in: .whitespaces)
            let name = (entry.userName ?? entry.originalUserName ?? "").trimmingCharacters(in: .whitespaces)
            let created = (entry.creationTimestamp ?? 0) > 0
                ? Date(timeIntervalSince1970: entry.creationTimestamp ?? 0)
                : Date()
            accounts.append(Account(
                issuer: issuer,
                name: name,
                secret: Base32.normalize(secret),
                algorithm: OTPAlgorithm(rawValue: (entry.algorithm ?? "SHA1").uppercased()) ?? .sha1,
                digits: (4...10).contains(entry.digits ?? 6) ? (entry.digits ?? 6) : 6,
                period: (entry.timeStep ?? 30) > 0 ? (entry.timeStep ?? 30) : 30,
                isFavorite: entry.isFavorite ?? false,
                folderID: entry.folderData?.folderId.flatMap { folderMap[$0]?.id },
                createdAt: created
            ))
        }
        return Result(accounts: accounts, folders: folders, skipped: skipped)
    }
}
