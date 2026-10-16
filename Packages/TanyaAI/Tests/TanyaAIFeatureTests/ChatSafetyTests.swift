//
//  ChatSafetyTests.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import TanyaAIDomain
@testable import TanyaAIFeature
import XCTest

@MainActor
final class ChatSafetyTests: XCTestCase
{
    func testDuplicateIntentAndActiveFlowOnlyCreateOneCard()
    {
        let fixture = TransferTestFixture()
        let model = makeModel(fixture)
        let intent = fixture.model.intent
        model.receive(.intent(intent, date: Date()))
        model.receive(.intent(intent, date: Date()))
        let other = TransferIntent(
            eventID: "other",
            flowID: "other-flow",
            messageID: "other-message",
            sessionID: "session",
            recipient: intent.recipient)
        model.receive(.intent(other, date: Date()))
        XCTAssertEqual(model.flows.count, 1)
        XCTAssertEqual(
            model.state.messages.filter
            {
                if case .transfer = $0.content
                {
                    return true
                }

                return false
            }

            .count,
            1)
        XCTAssertEqual(model.state.messages.count, 2)
    }

    func testFlowCardIDStaysStableAndRestorationHasNoRequests() async
    {
        let fixture = TransferTestFixture()
        let store = HistoryTestStore()
        let model = makeModel(fixture, history: store)
        model.receive(.intent(fixture.model.intent, date: Date()))
        guard let flow = model.flows[fixture.model.intent.flowID]
        else
        {
            return XCTFail("Missing flow")
        }

        flow.continueTapped()
        await flow.operation?.value
        flow.confirmTapped()
        await model.saveTask?.value
        let snapshot = await store.load(identity: model.context.identity)
        let restored = makeModel(fixture, history: store)
        restored.restore(snapshot)
        XCTAssertEqual(restored.state.messages.first?.id, fixture.model.intent.messageID)
        guard case .reviewing = restored.flows[fixture.model.intent.flowID]?.phase
        else
        {
            return XCTFail("Authorization restored")
        }

        restored.updateLanguage("zh-Hans")
        let counts = await (fixture.service.inquiries, fixture.service.submits)
        XCTAssertEqual(counts.0, 1)
        XCTAssertEqual(counts.1, 0)
    }

    func testCustomerAndSessionIsolation()
    {
        let fixture = TransferTestFixture()
        let model = makeModel(fixture)
        let wrong = TransferIntent(
            eventID: "wrong",
            flowID: "flow",
            messageID: "message",
            sessionID: "other-session",
            recipient: fixture.draft.recipient)
        model.receive(.intent(wrong, date: Date()))
        XCTAssertTrue(model.state.messages.isEmpty)
        model.restore(ConversationSnapshot(
            identity: SessionIdentity(customerID: "other", sessionID: "session"),
            revision: 1,
            messages: []))
        XCTAssertTrue(model.state.messages.isEmpty)
    }

    func testAllThreeLanguagesHaveLocalizedResources()
    {
        XCTAssertEqual(FeatureCopy(language: "id").continueAction, "Lanjut")
        XCTAssertEqual(FeatureCopy(language: "en").continueAction, "Continue")
        XCTAssertEqual(FeatureCopy(language: "zh-Hans").continueAction, "继续")
        XCTAssertTrue(FeatureCopy(language: "zh-Hans").noteCount(3, 25).contains("3"))
    }

    private func makeModel(_ fixture: TransferTestFixture, history: ConversationHistoryStoring = HistoryTestStore())
        -> ChatViewModel
    {
        let dependencies = TanyaAIDependencies(
            conversation: ChatTestService(),
            transfers: fixture.service,
            authorizer: fixture.authorizer,
            history: history,
            now:
            {
                Date(timeIntervalSince1970: 1000)
            },

            makeMessageID:
            {
                UUID().uuidString
            })
        return ChatViewModel(
            context: SessionContext(
                identity: SessionIdentity(customerID: "customer", sessionID: "session"),
                language: "en"),
            dependencies: dependencies,
            configuration: fixture.model.configuration)
    }
}
