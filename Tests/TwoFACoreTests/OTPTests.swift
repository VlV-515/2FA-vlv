import XCTest
@testable import TwoFACore

final class OTPTests: XCTestCase {
    // RFC 6238 appendix B, secret "12345678901234567890" (ASCII), 8 digits.
    private let rfcSecret = Base32.encode(Data("12345678901234567890".utf8))
    private let rfcSecret256 = Base32.encode(Data("12345678901234567890123456789012".utf8))
    private let rfcSecret512 = Base32.encode(Data("1234567890123456789012345678901234567890123456789012345678901234".utf8))

    private func totp(_ secret: String, _ algorithm: OTPAlgorithm, at time: TimeInterval) -> String? {
        OTP.code(
            for: Account(issuer: "t", name: "t", secret: secret, algorithm: algorithm, digits: 8),
            at: Date(timeIntervalSince1970: time)
        )
    }

    func testRFC6238SHA1() {
        XCTAssertEqual(totp(rfcSecret, .sha1, at: 59), "94287082")
        XCTAssertEqual(totp(rfcSecret, .sha1, at: 1111111109), "07081804")
        XCTAssertEqual(totp(rfcSecret, .sha1, at: 20000000000), "65353130")
    }

    func testRFC6238SHA256And512() {
        XCTAssertEqual(totp(rfcSecret256, .sha256, at: 59), "46119246")
        XCTAssertEqual(totp(rfcSecret512, .sha512, at: 59), "90693936")
    }

    func testHOTPRFC4226() {
        let expected = ["755224", "287082", "359152", "969429", "338314"]
        for (counter, code) in expected.enumerated() {
            let account = Account(issuer: "t", name: "t", secret: rfcSecret, kind: .hotp, counter: counter)
            XCTAssertEqual(OTP.code(for: account), code)
        }
    }

    func testSteamCodeShape() {
        let account = Account(issuer: "Steam", name: "x", secret: rfcSecret, kind: .steam, digits: 5)
        let code = OTP.code(for: account, at: Date(timeIntervalSince1970: 59))
        XCTAssertEqual(code?.count, 5)
    }

    func testInvalidSecretReturnsNil() {
        XCTAssertNil(OTP.code(for: Account(issuer: "t", name: "t", secret: "!!!")))
    }

    func testBase32RoundTripAndNormalize() {
        XCTAssertEqual(Base32.decode("mzxw 6ytb-oi======"), Data("foobar".utf8))
        XCTAssertEqual(Base32.encode(Data("foobar".utf8)), "MZXW6YTBOI")
        XCTAssertFalse(Base32.isValid("1890"))
    }

    func testSecondsRemaining() {
        XCTAssertEqual(OTP.secondsRemaining(period: 30, at: Date(timeIntervalSince1970: 60)), 30, accuracy: 0.001)
        XCTAssertEqual(OTP.secondsRemaining(period: 30, at: Date(timeIntervalSince1970: 89)), 1, accuracy: 0.001)
    }

    func testURIParse() throws {
        let uri = "otpauth://totp/Example%20Co:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example%20Co&digits=8&algorithm=SHA256&period=60"
        let account = try OTPAuthURI.parse(uri)
        XCTAssertEqual(account.issuer, "Example Co")
        XCTAssertEqual(account.name, "alice@example.com")
        XCTAssertEqual(account.digits, 8)
        XCTAssertEqual(account.algorithm, .sha256)
        XCTAssertEqual(account.period, 60)
    }

    func testURIErrors() {
        XCTAssertThrowsError(try OTPAuthURI.parse("https://example.com"))
        XCTAssertThrowsError(try OTPAuthURI.parse("otpauth://totp/x?issuer=y"))
        XCTAssertThrowsError(try OTPAuthURI.parse("otpauth://totp/x?secret=1890"))
    }

    func testURIRoundTrip() throws {
        let original = Account(issuer: "GitHub", name: "me", secret: "JBSWY3DPEHPK3PXP")
        let parsed = try OTPAuthURI.parse(OTPAuthURI.make(for: original))
        XCTAssertEqual(parsed.issuer, "GitHub")
        XCTAssertEqual(parsed.name, "me")
        XCTAssertEqual(parsed.secret, "JBSWY3DPEHPK3PXP")
    }

    func testLastPassImport() throws {
        let json = """
        {"deviceName":"x","version":1,"accounts":[
          {"issuerName":"B","userName":" bob ","secret":"JBSWY3DPEHPK3PXP","digits":6,"timeStep":30,"algorithm":"SHA1","isFavorite":true,"folderData":{"folderId":7,"position":1}},
          {"issuerName":"A","userName":"al","secret":"JBSWY3DPEHPK3PXP","digits":6,"timeStep":30,"algorithm":"SHA1","isFavorite":false,"folderData":{"folderId":0,"position":0}},
          {"issuerName":"Bad","userName":"x","secret":"!!","folderData":{"folderId":0,"position":2}}
        ],"folders":[{"id":1,"name":"Favoritos"},{"id":0,"name":"Otras cuentas"},{"id":7,"name":"Work"}]}
        """
        let result = try LastPassImporter.parse(Data(json.utf8))
        XCTAssertEqual(result.accounts.map(\.issuer), ["A", "B"])
        XCTAssertEqual(result.accounts[1].name, "bob")
        XCTAssertTrue(result.accounts[1].isFavorite)
        XCTAssertEqual(result.skipped, 1)
        XCTAssertEqual(result.folders.map(\.name), ["Work"])
        XCTAssertEqual(result.accounts[1].folderID, result.folders[0].id)
        XCTAssertNil(result.accounts[0].folderID)
    }

    func testLastPassInvalidFile() {
        XCTAssertThrowsError(try LastPassImporter.parse(Data("nope".utf8)))
    }
}
