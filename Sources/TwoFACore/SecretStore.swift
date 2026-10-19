import Foundation
import Security

/// Where secrets live when they are not inline in the vault file.
public protocol SecretStoring {
    func load() throws -> [UUID: String]
    func save(_ secrets: [UUID: String]) throws
    func delete() throws
}

public enum KeychainError: Error {
    case status(OSStatus)
}

/// One Keychain item holding every secret. One item means one access prompt, not one per account.
public struct KeychainSecretStore: SecretStoring {
    private let service: String
    private let account = "secrets"

    public init(service: String = "dev.vlv.2fa-vlv") {
        self.service = service
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    public func load() throws -> [UUID: String] {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return [:] }
        guard status == errSecSuccess, let data = result as? Data else { throw KeychainError.status(status) }
        let raw = try JSONDecoder().decode([String: String].self, from: data)
        return Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in
            UUID(uuidString: key).map { ($0, value) }
        })
    }

    public func save(_ secrets: [UUID: String]) throws {
        let raw = Dictionary(uniqueKeysWithValues: secrets.map { ($0.key.uuidString, $0.value) })
        let data = try JSONEncoder().encode(raw)
        let update = [kSecValueData as String: data]
        var status = SecItemUpdate(baseQuery as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            var add = baseQuery
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            status = SecItemAdd(add as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw KeychainError.status(status) }
    }

    public func delete() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.status(status) }
    }
}

/// In-memory store for tests.
public final class MemorySecretStore: SecretStoring {
    public var secrets: [UUID: String] = [:]
    public var failOnSave = false

    public init() {}

    public func load() throws -> [UUID: String] { secrets }

    public func save(_ secrets: [UUID: String]) throws {
        if failOnSave { throw KeychainError.status(-1) }
        self.secrets = secrets
    }

    public func delete() throws { secrets = [:] }
}
