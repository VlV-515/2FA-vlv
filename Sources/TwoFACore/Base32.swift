import Foundation

public enum Base32 {
    private static let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")

    /// Uppercase, strip spaces, dashes and padding.
    public static func normalize(_ string: String) -> String {
        string.uppercased().filter { $0 != " " && $0 != "-" && $0 != "=" && !$0.isNewline }
    }

    public static func isValid(_ string: String) -> Bool {
        let clean = normalize(string)
        return !clean.isEmpty && clean.allSatisfy { alphabet.contains($0) } && decode(clean) != nil
    }

    public static func decode(_ string: String) -> Data? {
        let clean = normalize(string)
        guard !clean.isEmpty else { return nil }
        var buffer: UInt32 = 0
        var bits = 0
        var output = Data()
        for char in clean {
            guard let index = alphabet.firstIndex(of: char) else { return nil }
            buffer = (buffer << 5) | UInt32(index)
            bits += 5
            if bits >= 8 {
                bits -= 8
                output.append(UInt8((buffer >> UInt32(bits)) & 0xFF))
            }
        }
        return output.isEmpty ? nil : output
    }

    public static func encode(_ data: Data) -> String {
        var result = ""
        var buffer: UInt32 = 0
        var bits = 0
        for byte in data {
            buffer = (buffer << 8) | UInt32(byte)
            bits += 8
            while bits >= 5 {
                bits -= 5
                result.append(alphabet[Int((buffer >> UInt32(bits)) & 0x1F)])
            }
        }
        if bits > 0 {
            result.append(alphabet[Int((buffer << UInt32(5 - bits)) & 0x1F)])
        }
        return result
    }
}
