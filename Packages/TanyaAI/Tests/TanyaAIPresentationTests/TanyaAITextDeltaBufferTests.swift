import XCTest
@testable import TanyaAIPresentation

final class TanyaAITextDeltaBufferTests: XCTestCase {
    func testBurstIsPublishedInOneOrderedBatch() {
        var batches: [String] = []
        let buffer = TanyaAITextDeltaBuffer { _, text in batches.append(text) }
        for index in 0..<1_000 {
            buffer.append(messageIdentifier: "same", text: "\(index),")
        }

        XCTAssertTrue(batches.isEmpty)
        buffer.flushAll()

        XCTAssertEqual(batches, [(0..<1_000).map { "\($0)," }.joined()])
    }

    func testCancelledBufferDoesNotPublishOrStayAlive() {
        var publishedCount = 0
        weak var released: TanyaAITextDeltaBuffer?
        autoreleasepool {
            let buffer = TanyaAITextDeltaBuffer { _, _ in publishedCount += 1 }
            buffer.append(messageIdentifier: "same", text: "Pending")
            buffer.cancel()
            released = buffer
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.08))

        XCTAssertNil(released)
        XCTAssertEqual(publishedCount, 0)
    }
}
