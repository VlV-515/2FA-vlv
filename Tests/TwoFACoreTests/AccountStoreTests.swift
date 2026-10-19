import XCTest
@testable import TwoFACore

final class AccountStoreTests: XCTestCase {
    private var url: URL!
    private var secrets: MemorySecretStore!

    override func setUp() {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("vault.json")
        secrets = MemorySecretStore()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    private func makeStore(secretStore: Bool = true) -> AccountStore {
        AccountStore(fileURL: url, secretStore: secrets, useSecretStore: secretStore)
    }

    private func account(_ issuer: String, fav: Bool = false, folder: UUID? = nil) -> Account {
        Account(issuer: issuer, name: "me", secret: "JBSWY3DPEHPK3PXP", isFavorite: fav, folderID: folder)
    }

    func testSecretsStayOutOfFileWhenUsingSecretStore() throws {
        let store = makeStore()
        store.add(account("A"))
        let text = try String(contentsOf: url)
        XCTAssertFalse(text.contains("JBSWY3DPEHPK3PXP"))
        XCTAssertEqual(secrets.secrets.values.first, "JBSWY3DPEHPK3PXP")

        let reloaded = makeStore()
        reloaded.load()
        XCTAssertEqual(reloaded.accounts.first?.secret, "JBSWY3DPEHPK3PXP")
    }

    func testInlineModeAndSwitching() throws {
        let store = makeStore(secretStore: false)
        store.add(account("A"))
        XCTAssertTrue(try String(contentsOf: url).contains("JBSWY3DPEHPK3PXP"))
        XCTAssertTrue(secrets.secrets.isEmpty)

        store.setUseSecretStore(true)
        XCTAssertFalse(try String(contentsOf: url).contains("JBSWY3DPEHPK3PXP"))
        XCTAssertEqual(secrets.secrets.count, 1)
    }

    func testFallsBackToInlineWhenSecretStoreFails() throws {
        secrets.failOnSave = true
        let store = makeStore()
        store.add(account("A"))
        XCTAssertNotNil(store.secretStoreError)
        let reloaded = makeStore()
        reloaded.load()
        XCTAssertEqual(reloaded.accounts.first?.secret, "JBSWY3DPEHPK3PXP")
    }

    func testSectionsAndSearch() {
        let store = makeStore()
        let work = store.addFolder(named: "Work")!
        store.add(account("Fav", fav: true))
        store.add(account("Slack", folder: work.id))
        store.add(account("Other"))
        XCTAssertEqual(store.sections(query: "").map(\.id), ["favorites", work.id.uuidString, "unfiled"])
        XCTAssertEqual(store.sections(query: "sla").flatMap(\.accounts).map(\.issuer), ["Slack"])
    }

    func testMoveWithinSection() {
        let store = makeStore()
        ["A", "B", "C"].forEach { store.add(account($0)) }
        store.move(in: "unfiled", from: IndexSet(integer: 2), to: 0)
        XCTAssertEqual(store.accounts.map(\.issuer), ["C", "A", "B"])
        store.move(in: "unfiled", from: IndexSet(integer: 0), to: 3)
        XCTAssertEqual(store.accounts.map(\.issuer), ["A", "B", "C"])
    }

    func testMoveKeepsOtherSectionsInPlace() {
        let store = makeStore()
        store.add(account("A"))
        store.add(account("F", fav: true))
        store.add(account("B"))
        store.move(in: "unfiled", from: IndexSet(integer: 1), to: 0)
        XCTAssertEqual(store.accounts.map(\.issuer), ["B", "F", "A"])
    }

    func testDeleteFolderUnfilesAccounts() {
        let store = makeStore()
        let folder = store.addFolder(named: "X")!
        store.add(account("A", folder: folder.id))
        store.deleteFolder(folder.id)
        XCTAssertNil(store.accounts[0].folderID)
        XCTAssertTrue(store.folders.isEmpty)
    }

    func testMergeSkipsDuplicates() {
        let store = makeStore()
        store.add(account("A"))
        let result = LastPassImporter.Result(accounts: [account("A"), account("B")], folders: [], skipped: 2)
        let summary = store.merge(result)
        XCTAssertEqual(summary, ImportSummary(added: 1, duplicates: 1, skipped: 2))
        XCTAssertEqual(store.accounts.count, 2)
    }
}
