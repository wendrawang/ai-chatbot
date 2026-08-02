import Foundation
import XCTest
@testable import TanyaAIData

final class TanyaAISSEParserTests: XCTestCase {
    func testFragmentedEventIsBufferedUntilComplete() {
        let parser = TanyaAISSEParser()

        let firstEvents = parser.append(Data("event: text.delta\ndata: {\"te".utf8))
        let secondEvents = parser.append(Data("xt\":\"Hello\"}\n\n".utf8))

        XCTAssertTrue(firstEvents.isEmpty)
        XCTAssertEqual(secondEvents.count, 1)
        XCTAssertEqual(secondEvents.first?.name, "text.delta")
        XCTAssertEqual(
            String(data: secondEvents[0].data, encoding: .utf8),
            #"{"text":"Hello"}"#
        )
    }

    func testMultipleEventsInOneChunkAreParsedInOrder() {
        let parser = TanyaAISSEParser()
        let source = "event: heartbeat\ndata: {}\n\n"
            + "event: response.completed\ndata: {\"messageIdentifier\":\"one\"}\n\n"

        let events = parser.append(Data(source.utf8))

        XCTAssertEqual(events.map(\.name), ["heartbeat", "response.completed"])
    }

    func testCommentIsMappedToHeartbeat() {
        let parser = TanyaAISSEParser()

        let events = parser.append(Data(": keep-alive\n\n".utf8))

        XCTAssertEqual(events.first?.name, "heartbeat")
    }
}
