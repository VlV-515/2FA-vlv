import XCTest
@testable import TwoFACore

/// Runs only when the (gitignored) personal LastPass backup sits in the repo root.
final class PersonalBackupTests: XCTestCase {
    func testPersonalBackupImportsAndGeneratesCodes() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("data-example.json")
        guard let data = try? Data(contentsOf: url) else {
            throw XCTSkip("data-example.json not present")
        }
        let result = try LastPassImporter.parse(data)
        XCTAssertFalse(result.accounts.isEmpty)
        XCTAssertEqual(result.skipped, 0)
        for account in result.accounts {
            XCTAssertNotNil(OTP.code(for: account), "bad secret for \(account.issuer)")
        }
    }
}
