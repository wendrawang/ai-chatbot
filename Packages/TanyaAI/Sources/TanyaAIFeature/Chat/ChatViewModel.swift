//
//  ChatViewModel.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Combine
import Foundation
import TanyaAIDomain

@MainActor
final class ChatViewModel: ObservableObject
{
    let context: SessionContext
    let dependencies: TanyaAIDependencies
    let configuration: TransferConfiguration
    @Published var state: ChatState
    var flows: [String: TransferFlowViewModel]
    var seenEvents: Set<String>
    var historyRevision: Int
    var streamTask: Task<Void, Never>?
    var saveTask: Task<Void, Never>?
    var sendTask: Task<Void, Never>?
    private var isStarted: Bool
    init(context: SessionContext, dependencies: TanyaAIDependencies, configuration: TransferConfiguration)
    {
        self.context = context
        self.dependencies = dependencies
        self.configuration = configuration
        state = ChatState(language: context.language)
        flows = [:]
        seenEvents = []
        historyRevision = 0
        isStarted = false
    }

    deinit
    {
        streamTask?.cancel()
        saveTask?.cancel()
        sendTask?.cancel()
        let service = dependencies.conversation
        Task
        {
            await service.close()
        }
    }

    func start()
    {
        guard !isStarted
        else
        {
            return
        }

        isStarted = true
        streamTask = Task
        {
            [weak self, context, dependencies] in
            let restored = await dependencies.history.load(identity: context.identity)
            guard !Task.isCancelled
            else
            {
                return
            }

            self?.restore(restored)
            do
            {
                let stream = try await dependencies.conversation.open(context: context)
                for try await event in stream
                {
                    guard !Task.isCancelled
                    else
                    {
                        return
                    }

                    self?.receive(event)
                }
            }

            catch
            {
                self?.appendNotice(FeatureCopy(language: context.language).connectionFailed)
            }
        }
    }

    func send(_ text: String)
    {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty
        else
        {
            return
        }

        let id = dependencies.makeMessageID()
        state.messages.append(ChatMessage(id: id, date: dependencies.now(), revision: 0, content: .user(text)))
        state.promptAnchor = id
        persist()
        dispatch(.text(text, language: state.language))
    }

    func transferTapped()
    {
        let copy = FeatureCopy(language: state.language)
        let id = dependencies.makeMessageID()
        state.messages.append(ChatMessage(id: id, date: dependencies.now(), revision: 0, content: .user(copy.transfer)))
        state.promptAnchor = id
        persist()
        dispatch(.transfer)
    }

    func updateLanguage(_ language: String)
    {
        state.language = language
    }

    func showLatest()
    {
        state.promptAnchor = nil
        state.latestRequest += 1
    }

    func pauseTransientInput()
    {
        for flow in flows.values
        {
            guard case .authorizing = flow.phase
            else
            {
                continue
            }

            flow.pinBackTapped()
        }
    }

    func restore(_ snapshot: ConversationSnapshot?)
    {
        guard let snapshot, snapshot.identity == context.identity
        else
        {
            return
        }

        state.messages = snapshot.messages
        historyRevision = snapshot.revision
        for message in snapshot.messages
        {
            guard case let .transfer(transfer) = message.content
            else
            {
                continue
            }

            seenEvents.insert(transfer.intent.eventID)
            installFlow(transfer)
        }
    }

    func installFlow(_ snapshot: TransferSnapshot)
    {
        let flow = TransferFlowViewModel(
            snapshot: snapshot,
            service: dependencies.transfers,
            authorizer: dependencies.authorizer,
            configuration: configuration)
        flow.onChange =
        {
            [weak self] snapshot in
            self?.updateFlow(snapshot)
        }

        flows[snapshot.intent.flowID] = flow
    }

    func persist()
    {
        historyRevision += 1
        let snapshot = ConversationSnapshot(
            identity: context.identity,
            revision: historyRevision,
            messages: state.messages)
        let previous = saveTask
        saveTask = Task
        {
            [dependencies] in
            await previous?.value
            await dependencies.history.save(snapshot)
        }
    }

    func appendNotice(_ text: String)
    {
        state.messages.append(ChatMessage(
            id: dependencies.makeMessageID(),
            date: dependencies.now(),
            revision: 0,
            content: .answer(text, isStreaming: false)))
        persist()
    }

    private func dispatch(_ request: ConversationRequest)
    {
        let previous = sendTask
        sendTask = Task
        {
            [weak self, dependencies] in
            await previous?.value
            do
            {
                try await dependencies.conversation.send(request)
            }

            catch
            {
                self?.appendNotice(FeatureCopy(language: self?.state.language ?? "en").connectionFailed)
            }
        }
    }
}
