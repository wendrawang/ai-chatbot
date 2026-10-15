import Foundation
import TanyaAIContracts
import TanyaAIDomain
import TanyaAITestSupport
import XCTest

final class MockFigmaResponseFixtureTests: XCTestCase {
    func testEveryDemoRouteProducesValidOrderedResponseAndCompletion() throws {
        let prompts = [
            "Cek Portofolio", "Cek performa investasiku", "Optimalkan investasi yang kurang produktif",
            "Lihat pilihan produk", "Beli produk", "Manulife Dana Kas II Kelas A",
            "Ashmore Dana Ekuitas Nusantara", "Beli Sekarang", "5jt", "Konfirmasi Pembelian",
            "__transaction_success__", "Any other prompt"
        ]
        for prompt in prompts {
            let events = MockFigmaResponseFixture.events(for: prompt)
            let envelopes = try decode(events)
            XCTAssertFalse(envelopes.isEmpty, prompt)
            XCTAssertTrue(envelopes.allSatisfy { !$0.response.blocks.isEmpty }, prompt)
            guard case .messageCompleted(let identifier) = events.last else {
                return XCTFail("Fixture does not complete its incoming message: \(prompt)")
            }
            XCTAssertEqual(identifier, envelopes.last?.messageIdentifier)
        }
    }

    func testActivityIsReplacedOnSameMessageIdentifier() throws {
        let envelopes = try decode(MockFigmaResponseFixture.events(for: "Cek performa investasiku"))
        XCTAssertEqual(envelopes.count, 2)
        XCTAssertEqual(envelopes[0].messageIdentifier, envelopes[1].messageIdentifier)
        XCTAssertEqual(envelopes[0].response.blocks, [.activity("Checking your investment…")])
        XCTAssertFalse(
            envelopes[1].response.blocks.contains {
                if case .activity = $0 { return true }
                return false
            })
    }

    func testDemoTablesUseTwoOrThreeSharedColumns() throws {
        for (prompt, count) in [("Lihat pilihan produk", 2), ("Cek performa investasiku", 3)] {
            let envelopes = try decode(MockFigmaResponseFixture.events(for: prompt))
            let blocks = try XCTUnwrap(envelopes.last?.response.blocks)
            var tableCount = 0
            for case .table(let table) in blocks {
                tableCount += 1
                XCTAssertEqual(table.columns.count, count)
                XCTAssertEqual(table.rows.count, 3)
            }
            XCTAssertEqual(tableCount, 1)
        }
    }

    func testProductOptionsHaveThreeDistinctChoicesAndNoPreselection() throws {
        let envelopes = try decode(MockFigmaResponseFixture.events(for: "Beli produk"))
        guard case .options(let options) = envelopes.last?.response.blocks.first else {
            return XCTFail("Missing product options")
        }
        XCTAssertEqual(options.choices.count, 3)
        XCTAssertEqual(Set(options.choices.map(\.identifier)).count, 3)
        XCTAssertNil(options.selectedIdentifier)
        XCTAssertFalse(options.isReadOnly)
    }

    func testSummaryPreservesChosenProductAndSeparatesEditingFromPrompt() throws {
        let selected = "Ashmore Dana Ekuitas Nusantara"
        let envelopes = try decode(MockFigmaResponseFixture.events(for: "5jt", productTitle: selected))
        let blocks = try XCTUnwrap(envelopes.last?.response.blocks)
        guard case .summary(let summary) = blocks[1], case .actions(let actions) = blocks[2] else {
            return XCTFail("Missing purchase summary/actions")
        }
        XCTAssertEqual(summary.title, selected)
        XCTAssertEqual(summary.fields.last?.value, "IDR 5.003.000")
        XCTAssertEqual(summary.fields.last?.isEmphasized, true)
        XCTAssertEqual(actions[0].intent, .prompt)
        XCTAssertEqual(actions[1].intent, .edit)
        XCTAssertEqual(actions[1].target, "")
    }

    func testDocumentsRequireBothHostAcknowledgementsBeforePIN() throws {
        let envelopes = try decode(MockFigmaResponseFixture.events(for: "Konfirmasi Pembelian"))
        guard case .documents(let documents) = envelopes.last?.response.blocks.last else {
            return XCTFail("Missing document checklist")
        }
        XCTAssertEqual(documents.identifier, "confirmation-demo")
        XCTAssertEqual(documents.documents.map(\.identifier), ["doc-product", "doc-terms"])
        XCTAssertTrue(documents.documents.allSatisfy { $0.destination?.hasPrefix("ocbcid://") == true })
        XCTAssertFalse(documents.isReady)
        XCTAssertFalse(documents.isAuthorized)
    }

    func testFormattedFallbackUsesNativeMarkupForLinksAndBullets() throws {
        let envelopes = try decode(MockFigmaResponseFixture.events(for: "Anything"))
        guard case .text(let text) = envelopes.last?.response.blocks.first else {
            return XCTFail("Missing formatted text")
        }
        XCTAssertTrue(text.contains("[bold]"))
        XCTAssertTrue(text.contains("[strike]"))
        XCTAssertTrue(text.contains("[color]"))
        XCTAssertTrue(text.contains("[link]https://www.google.com|Buka Google[/link]"))
        XCTAssertTrue(text.contains("[link]ocbcid://mobile?type=portfolio|Lihat portofolio[/link]"))
        XCTAssertTrue(text.contains("• "))
        XCTAssertFalse(text.contains("<html"))
    }

    private func decode(_ events: [TanyaAIChatSessionEvent]) throws -> [FixtureEnvelope] {
        try events.compactMap { event in
            switch event {
            case .structuredPayload(let name, let json):
                XCTAssertEqual(name, "response")
                return try JSONDecoder().decode(FixtureEnvelope.self, from: json)
            case .messageCompleted: return nil
            default: throw CocoaError(.coderReadCorrupt)
            }
        }
    }
}

private struct FixtureEnvelope: Decodable {
    let messageIdentifier: String
    let response: ResponsePayload
}
