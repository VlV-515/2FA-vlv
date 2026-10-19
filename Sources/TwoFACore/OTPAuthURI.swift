import Foundation

public enum OTPAuthURI {
    public enum ParseError: Error, Equatable {
        case notOTPAuth
        case unsupportedType
        case missingSecret
        case invalidSecret
    }

    public static func parse(_ text: String) throws -> Account {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let components = URLComponents(string: trimmed),
              components.scheme?.lowercased() == "otpauth" else {
            throw ParseError.notOTPAuth
        }

        let host = (components.host ?? "").lowercased()
        let query = Dictionary(
            (components.queryItems ?? []).compactMap { item in item.value.map { (item.name.lowercased(), $0) } },
            uniquingKeysWith: { first, _ in first }
        )

        var kind: OTPKind
        switch host {
        case "totp": kind = .totp
        case "hotp": kind = .hotp
        case "steam": kind = .steam
        default: throw ParseError.unsupportedType
        }
        if query["encoder"]?.lowercased() == "steam" { kind = .steam }

        guard let secret = query["secret"], !secret.isEmpty else { throw ParseError.missingSecret }
        guard Base32.isValid(secret) else { throw ParseError.invalidSecret }

        var label = components.path
        if label.hasPrefix("/") { label.removeFirst() }
        label = label.removingPercentEncoding ?? label

        var issuer = query["issuer"] ?? ""
        var name = label
        if let colon = label.firstIndex(of: ":") {
            let labelIssuer = String(label[..<colon]).trimmingCharacters(in: .whitespaces)
            name = String(label[label.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
            if issuer.isEmpty { issuer = labelIssuer }
        }

        let algorithm = OTPAlgorithm(rawValue: (query["algorithm"] ?? "SHA1").uppercased()) ?? .sha1
        let digits = Int(query["digits"] ?? "") ?? (kind == .steam ? 5 : 6)
        let period = Int(query["period"] ?? "") ?? 30
        let counter = Int(query["counter"] ?? "") ?? 0

        return Account(
            issuer: issuer,
            name: name,
            secret: Base32.normalize(secret),
            kind: kind,
            algorithm: algorithm,
            digits: (4...10).contains(digits) ? digits : 6,
            period: period > 0 ? period : 30,
            counter: counter
        )
    }

    public static func make(for account: Account) -> String {
        var components = URLComponents()
        components.scheme = "otpauth"
        components.host = account.kind == .hotp ? "hotp" : "totp"
        let label = account.issuer.isEmpty ? account.name : "\(account.issuer):\(account.name)"
        components.path = "/" + label
        var items = [
            URLQueryItem(name: "secret", value: Base32.normalize(account.secret)),
            URLQueryItem(name: "algorithm", value: account.algorithm.rawValue),
            URLQueryItem(name: "digits", value: String(account.digits))
        ]
        if !account.issuer.isEmpty { items.append(URLQueryItem(name: "issuer", value: account.issuer)) }
        if account.kind == .hotp {
            items.append(URLQueryItem(name: "counter", value: String(account.counter)))
        } else {
            items.append(URLQueryItem(name: "period", value: String(account.period)))
        }
        if account.kind == .steam { items.append(URLQueryItem(name: "encoder", value: "steam")) }
        components.queryItems = items
        return components.string ?? ""
    }
}
