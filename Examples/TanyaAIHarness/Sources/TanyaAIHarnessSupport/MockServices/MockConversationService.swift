//
//  MockConversationService.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

public actor MockConversationService: ConversationServicing
{
    private let configuration: DemoConfiguration
    private var continuation: AsyncThrowingStream<ConversationEvent, Error>.Continuation?
    private var context: SessionContext?
    private var sequence: Int
    private var opening: Task<Void, Never>?
    public init(configuration: DemoConfiguration)
    {
        self.configuration = configuration
        sequence = 0
    }

    public func open(context: SessionContext) async throws -> AsyncThrowingStream<ConversationEvent, Error>
    {
        self.context = context
        let stream = AsyncThrowingStream<ConversationEvent, Error>
        {
            continuation in
            self.continuation = continuation
        }

        opening = Task
        {
            [weak self] in
            await self?.greet()
        }

        return stream
    }

    public func send(_ request: ConversationRequest) async throws
    {
        guard let context
        else
        {
            return
        }

        switch request
        {
        case .transfer:
            emitIntent(context)
        case let .text(text, language):
            guard text.lowercased().contains("transfer") || text.contains("转账")
            else
            {
                try await answer(HarnessCopy(language: language).fallback, id: nextID("answer"))
                return
            }

            emitIntent(context)
        }
    }

    public func close() async
    {
        opening?.cancel()
        continuation?.finish()
        continuation = nil
    }

    private func greet() async
    {
        guard let context
        else
        {
            return
        }

        do
        {
            try await answer(HarnessCopy(language: context.language).greeting, id: "greeting")
            continuation?.yield(.suggestion(id: "transfer-suggestion", date: configuration.date))
        }

        catch
        {
            return
        }
    }

    private func answer(_ text: String, id: String) async throws
    {
        continuation?.yield(.answerStarted(id: id, date: configuration.date))
        // Short chunks intentionally split bracket tags and Unicode grapheme boundaries safely.
        let characters = Array(text)
        for offset in stride(from: 0, to: characters.count, by: 12)
        {
            try Task.checkCancellation()
            let chunk = String(characters[offset ..< min(offset + 12, characters.count)])
            continuation?.yield(.textDelta(id: id, text: chunk))
            try await Task.sleep(nanoseconds: configuration.delay / 6)
        }

        continuation?.yield(.answerFinished(id: id))
    }

    private func emitIntent(_ context: SessionContext)
    {
        let id = nextID("intent")
        let intent = TransferIntent(
            eventID: id,
            flowID: id + "-flow",
            messageID: id + "-message",
            sessionID: context.identity.sessionID,
            recipient: configuration.recipient)
        continuation?.yield(.intent(intent, date: configuration.date))
        guard configuration.scenario == .duplicateIntent
        else
        {
            return
        }

        continuation?.yield(.intent(intent, date: configuration.date))
    }

    private func nextID(_ prefix: String) -> String
    {
        sequence += 1
        return prefix + "-" + String(sequence)
    }
}
