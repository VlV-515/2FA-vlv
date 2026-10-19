import Foundation

public enum OTPKind: String, Codable, CaseIterable, Sendable {
    case totp
    case hotp
    case steam
}

public enum OTPAlgorithm: String, Codable, CaseIterable, Sendable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"
}

public struct Account: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var issuer: String
    public var name: String
    /// Base32 shared secret.
    public var secret: String
    public var kind: OTPKind
    public var algorithm: OTPAlgorithm
    public var digits: Int
    /// Seconds per code (TOTP / Steam).
    public var period: Int
    /// Next counter value (HOTP only).
    public var counter: Int
    public var isFavorite: Bool
    public var folderID: UUID?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        issuer: String,
        name: String,
        secret: String,
        kind: OTPKind = .totp,
        algorithm: OTPAlgorithm = .sha1,
        digits: Int = 6,
        period: Int = 30,
        counter: Int = 0,
        isFavorite: Bool = false,
        folderID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.issuer = issuer
        self.name = name
        self.secret = secret
        self.kind = kind
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
        self.counter = counter
        self.isFavorite = isFavorite
        self.folderID = folderID
        self.createdAt = createdAt
    }

    public var title: String { issuer.isEmpty ? name : issuer }

    public var subtitle: String { issuer.isEmpty ? "" : name }

    /// Same service + login + secret means same account.
    func isDuplicate(of other: Account) -> Bool {
        Base32.normalize(secret) == Base32.normalize(other.secret)
            && issuer.lowercased() == other.issuer.lowercased()
            && name.lowercased() == other.name.lowercased()
    }
}

public struct Folder: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
