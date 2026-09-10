import Foundation
import TanyaAIContracts
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

/// Reopening a conversation has to show both sides of it. Only the channel
/// knows which turns were the customer's, so the mapping is asserted here.
final class TanyaAISessionHistoryTests: XCTestCase {
    func testHistoryKeepsBothSidesOfTheConversation() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        repository.observeUnsolicitedEvents { events.append($0) }

        session.emit(.history([
            message(identifier: "1", author: .customer, text: "Halo"),
            message(identifier: "2", author: .assistant, text: "Ada yang bisa dibantu?")
        ]))

        guard case .history(let restored)? = events.first else {
            return XCTFail("Expected a history event")
        }
        XCTAssertEqual(restored.map(\.role), [.user, .assistant])
        XCTAssertEqual(restored.map(\.id), ["1", "2"])
        withExtendedLifetime(repository) {}
    }

    func testHistoryCardDecodesToItsTypedContent() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        repository.observeUnsolicitedEvents { events.append($0) }

        session.emit(.history([
            TanyaAIChatSessionMessage(
                identifier: "3",
                author: .assistant,
                text: "Status",
                structuredName: "content.status",
                structuredJSON: statusJSON
            )
        ]))

        guard case .history(let restored)? = events.first,
              case .status(let payload)? = restored.first?.content else {
            return XCTFail("Expected a typed status bubble")
        }
        XCTAssertEqual(payload.title, "Selesai")
        withExtendedLifetime(repository) {}
    }

    /// A card the app can no longer read must not drop out of the
    /// conversation: the turn it belonged to still happened.
    func testUnreadableHistoryCardDegradesInsteadOfVanishing() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        repository.observeUnsolicitedEvents { events.append($0) }

        session.emit(.history([
            TanyaAIChatSessionMessage(
                identifier: "4",
                author: .assistant,
                text: "Kartu",
                structuredName: "content.status",
                structuredJSON: Data("not-json".utf8)
            )
        ]))

        guard case .history(let restored)? = events.first,
              case .unsupported? = restored.first?.content else {
            return XCTFail("Expected the unsupported fallback")
        }
        XCTAssertEqual(restored.count, 1)
        withExtendedLifetime(repository) {}
    }

    /// A session that opens without sending history has none, and the screen
    /// has to learn that or it waits on a batch that never comes.
    func testConnectingWithoutHistoryReportsAnEmptyOne() {
        let session = SessionSpy()
        let repository = TanyaAISessionRepository(session: session)
        var events: [TanyaAIStreamEvent] = []
        repository.observeUnsolicitedEvents { events.append($0) }

        session.emit(.connected)

        guard case .history(let restored)? = events.first else {
            return XCTFail("Expected an empty history event")
        }
        XCTAssertTrue(restored.isEmpty)
        withExtendedLifetime(repository) {}
    }

    private func message(
        identifier: String,
        author: TanyaAIChatSessionMessage.Author,
        text: String
    ) -> TanyaAIChatSessionMessage {
        TanyaAIChatSessionMessage(
            identifier: identifier,
            author: author,
            text: text
        )
    }

    private var statusJSON: Data {
        Data("""
        {"messageIdentifier":"st-1","title":"Selesai",
         "detail":"Permintaan diproses.","level":"success"}
        """.utf8)
    }
}
