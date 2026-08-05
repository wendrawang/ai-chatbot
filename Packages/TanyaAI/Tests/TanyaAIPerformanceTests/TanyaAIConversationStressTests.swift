import XCTest
@testable import TanyaAIPresentation

final class TanyaAIConversationStressTests: XCTestCase {
    func testFiveThousandMessageIngestionPerformance() {
        let options = XCTMeasureOptions()
        options.iterationCount = 3

        measure(
            metrics: [XCTClockMetric(), XCTMemoryMetric()],
            options: options
        ) {
            autoreleasepool {
                let useCase = TanyaAIChatUseCaseFixture()
                let viewModel = TanyaAIChatViewModel(useCase: useCase)
                viewModel.sendMessage("stress fixture")
                useCase.appendStatusMessages(count: 5_000)

                XCTAssertEqual(viewModel.messages.count, 5_002)
                XCTAssertEqual(
                    viewModel.messages.last?.id,
                    "performance-4999"
                )
            }
        }
    }
}
