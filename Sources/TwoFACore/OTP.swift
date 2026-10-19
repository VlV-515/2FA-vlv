import CryptoKit
import Foundation

public enum OTP {
    private static let steamAlphabet = Array("23456789BCDFGHJKMNPQRTVWXY")

    /// Code for `account` at `date`. Returns nil when secret is not valid Base32.
    public static func code(for account: Account, at date: Date = Date()) -> String? {
        guard let key = Base32.decode(account.secret) else { return nil }
        switch account.kind {
        case .totp:
            let counter = timeCounter(date: date, period: account.period)
            let value = truncated(key: key, counter: counter, algorithm: account.algorithm)
            return format(value, digits: account.digits)
        case .hotp:
            let value = truncated(key: key, counter: UInt64(max(account.counter, 0)), algorithm: account.algorithm)
            return format(value, digits: account.digits)
        case .steam:
            var value = truncated(key: key, counter: timeCounter(date: date, period: account.period), algorithm: .sha1)
            var result = ""
            for _ in 0..<5 {
                result.append(steamAlphabet[Int(value % UInt32(steamAlphabet.count))])
                value /= UInt32(steamAlphabet.count)
            }
            return result
        }
    }

    /// Seconds left in the current period.
    public static func secondsRemaining(period: Int, at date: Date = Date()) -> Double {
        let p = Double(max(period, 1))
        let elapsed = date.timeIntervalSince1970.truncatingRemainder(dividingBy: p)
        return p - elapsed
    }

    static func timeCounter(date: Date, period: Int) -> UInt64 {
        UInt64(max(date.timeIntervalSince1970, 0) / Double(max(period, 1)))
    }

    /// RFC 4226 dynamic truncation, 31-bit result.
    static func truncated(key: Data, counter: UInt64, algorithm: OTPAlgorithm) -> UInt32 {
        var big = counter.bigEndian
        let message = Data(bytes: &big, count: MemoryLayout<UInt64>.size)
        let symmetric = SymmetricKey(data: key)
        let mac: [UInt8]
        switch algorithm {
        case .sha1: mac = Array(HMAC<Insecure.SHA1>.authenticationCode(for: message, using: symmetric))
        case .sha256: mac = Array(HMAC<SHA256>.authenticationCode(for: message, using: symmetric))
        case .sha512: mac = Array(HMAC<SHA512>.authenticationCode(for: message, using: symmetric))
        }
        let offset = Int(mac[mac.count - 1] & 0x0F)
        return (UInt32(mac[offset] & 0x7F) << 24)
            | (UInt32(mac[offset + 1]) << 16)
            | (UInt32(mac[offset + 2]) << 8)
            | UInt32(mac[offset + 3])
    }

    private static func format(_ value: UInt32, digits: Int) -> String {
        let d = min(max(digits, 4), 10)
        var modulus: UInt64 = 1
        for _ in 0..<d { modulus *= 10 }
        let number = String(UInt64(value) % modulus)
        return String(repeating: "0", count: max(0, d - number.count)) + number
    }
}
