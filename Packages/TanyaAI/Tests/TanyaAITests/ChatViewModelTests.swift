//
//  ChatViewModelTests.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import XCTest

@testable import TanyaAI

@MainActor
final class ChatViewModelTests: XCTestCase {
    private let service = FakeChatService()
    private var links: [TanyaAILink] = []

    private func makeModel() -> ChatViewModel {
        ChatViewModel(
            service: service, locale: { Locale(identifier: "id") },
            onOpenLink: { [weak self] in self?.links.append($0) }
        )
    }

    func testFreeTextStreamsMarkupAndBlocksIntoOneAnswer() async throws {
        service.events = [
            FakeChatService.event("status", #"{"text":"Processing"}"#),
            FakeChatService.event("delta", #"{"delta":"Saya [bold]wen"}"#),
            FakeChatService.event("delta", #"{"delta":"dra[/bold]"}"#),
            FakeChatService.event("blocks", #"{"blocks":[{"type":"text","text":"Lanjut"}]}"#),
            FakeChatService.event("end", "{}")
        ]
        let model = makeModel()
        XCTAssertTrue(model.send("  halo  "))
        await waitUntil { !model.isResponding }
        XCTAssertEqual(service.requests.first?.text, "halo")
        XCTAssertEqual(model.messages.map(\.role), [.user, .assistant])
        let answer = try XCTUnwrap(model.messages.last)
        XCTAssertEqual(answer.text, "Saya [bold]wendra[/bold]")
        XCTAssertEqual(answer.blocks, [.text("Lanjut")])
        XCTAssertNil(answer.status)
        XCTAssertFalse(model.send("   "))
    }

    func testIntentRunsBackendInquiryWithIdAndParametersThenMapsTheResult() async throws {
        service.events = [
            FakeChatService.event("status", #"{"text":"Checking"}"#),
            FakeChatService.event(
                "intent", #"{"intent":{"name":"review-porto","inquiryId":"inq-9","parameters":{"type":"mf"}}}"#),
            FakeChatService.event("end", "{}")
        ]
        service.inquiryResponse = Data(#"{"summary":"Ringkas","holdings":[],"totalProfit":0}"#.utf8)
        let model = makeModel()
        model.send("cek porto")
        await waitUntil { !model.isResponding }
        XCTAssertEqual(
            service.inquiries, [TanyaAIIntent(name: "review-porto", inquiryId: "inq-9", parameters: ["type": "mf"])])
        let answer = try XCTUnwrap(model.messages.last)
        XCTAssertEqual(answer.blocks.first, .text("Ringkas"))
        XCTAssertNil(answer.status)
    }

    func testStopEndsTheAnswerAndTheNextQuestionIsNotDisturbed() async {
        service.isHoldingStream = true
        service.events = [FakeChatService.event("status", #"{"text":"Processing"}"#)]
        let model = makeModel()
        model.send("panjang")
        await waitUntil { model.messages.last?.status == "Processing" }
        model.stop()
        XCTAssertFalse(model.isResponding)
        XCTAssertEqual(model.messages.last?.text, "Jawaban dihentikan.")
        service.isHoldingStream = false
        service.events = [FakeChatService.event("delta", #"{"delta":"Baru"}"#)]
        XCTAssertTrue(model.send("lagi"))
        await waitUntil { !model.isResponding }
        XCTAssertEqual(model.messages.last?.text, "Baru")
        XCTAssertEqual(model.messages[1].text, "Jawaban dihentikan.")
    }

    func testRetryableErrorOffersTryAgainWithTheSamePrompt() async throws {
        service.events = [FakeChatService.event("error", #"{"isRetryable":true}"#)]
        let model = makeModel()
        model.send("halo")
        await waitUntil { !model.isResponding }
        let answer = try XCTUnwrap(model.messages.last)
        XCTAssertEqual(answer.text, "Maaf, terjadi kendala. Silakan coba lagi.")
        guard case .actions(let actions) = answer.blocks.first else { return XCTFail("Tidak ada tombol coba lagi") }
        XCTAssertEqual(actions.first?.label, "Coba lagi")
        XCTAssertEqual(actions.first?.action, ActionTarget(type: .prompt, value: "halo", parameters: nil))
    }

    func testOptionBecomesReadOnlyHistoryAndOlderAnswersStopBeingInteractive() async throws {
        service.events = [
            FakeChatService.event(
                "blocks", #"{"blocks":[{"type":"options","id":"o","items":[{"id":"p1","label":"Satu"}]}]}"#)
        ]
        let model = makeModel()
        model.send("pilih")
        await waitUntil { !model.isResponding }
        let answerId = try XCTUnwrap(model.messages.last?.id)
        model.select(OptionsBlock.Item(id: "p1", label: "Satu", action: nil), blockIndex: .zero, messageId: answerId)
        await waitUntil { !model.isResponding }
        XCTAssertEqual(model.messages[1].selections, [.zero: "p1"])
        XCTAssertFalse(model.messages[1].isInteractive)
        XCTAssertEqual(service.requests.last?.text, "Satu")
        XCTAssertTrue(try XCTUnwrap(model.messages.last).isInteractive)
    }

    func testNewConversationClearsMessagesAndUsesANewConversationId() async {
        let model = makeModel()
        model.send("halo")
        await waitUntil { !model.isResponding }
        let firstId = service.requests.first?.conversationId
        model.startNewConversation()
        XCTAssertTrue(model.messages.isEmpty)
        model.send("lagi")
        await waitUntil { !model.isResponding }
        XCTAssertNotEqual(service.requests.last?.conversationId, firstId)
    }

    func testLinksAreClassifiedForTheHost() throws {
        let model = makeModel()
        model.openLink(try XCTUnwrap(URL(string: "https://ocbc.id")))
        model.openLink(try XCTUnwrap(URL(string: "ocbcid://investment")))
        model.openLink(try XCTUnwrap(URL(string: "tel:1500999")))
        model.perform(ActionTarget(type: .link, value: "javascript:alert(1)", parameters: nil), label: "x")
        XCTAssertEqual(links.count, 3)
        guard case .web = links[0], case .deeplink = links[1], case .phone = links[2] else {
            return XCTFail("Klasifikasi link salah: \(links)")
        }
    }
}
