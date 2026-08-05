import Foundation
import XCTest
@testable import TanyaAIData

final class TanyaAISSEPerformanceTests: XCTestCase {
    func testParsingOneThousandEventsPerformance() {
        let data = makeEvents(count: 1_000)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let parser = TanyaAISSEParser()
            let events = parser.append(data)
            XCTAssertEqual(events.count, 1_000)
        }
    }

    private func makeEvents(count: Int) -> Data {
        let source = (0..<count).map { index in
            "event: text.delta\n"
                + "data: {\"messageIdentifier\":\"\(index)\","
                + "\"text\":\"sample\"}\n\n"
        }.joined()
        return Data(source.utf8)
    }
}
