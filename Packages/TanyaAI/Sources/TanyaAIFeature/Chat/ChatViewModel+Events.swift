//
//  ChatViewModel+Events.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import TanyaAIDomain

extension ChatViewModel
{
    func receive(_ event: ConversationEvent)
    {
        switch event
        {
        case let .answerStarted(id, date):
            guard !state.messages.contains(where:
                {
                    $0.id == id
                })
            else
            {
                return
            }

            state.messages.append(ChatMessage(id: id, date: date, revision: 0, content: .answer("", isStreaming: true)))
        case let .textDelta(id, text):
            appendDelta(text, id: id)
        case let .answerFinished(id):
            finishAnswer(id)
        case let .suggestion(id, date):
            guard !state.messages.contains(where:
                {
                    $0.id == id
                })
            else
            {
                return
            }

            state.messages.append(ChatMessage(id: id, date: date, revision: 0, content: .suggestion))
        case let .intent(intent, date):
            receiveIntent(intent, date: date)
        }

        persist()
    }

    private func appendDelta(_ text: String, id: String)
    {
        guard let index = state.messages.firstIndex(where:
            {
                $0.id == id
            }),
            case .answer(let previous, true) = state.messages[index].content
        else
        {
            return
        }

        state.messages[index].content = .answer(previous + text, isStreaming: true)
        state.messages[index].revision += 1
    }

    private func finishAnswer(_ id: String)
    {
        guard let index = state.messages.firstIndex(where:
            {
                $0.id == id
            }),
            case let .answer(text, _) = state.messages[index].content
        else
        {
            return
        }

        state.messages[index].content = .answer(text, isStreaming: false)
        state.messages[index].revision += 1
    }

    private func receiveIntent(_ intent: TransferIntent, date: Date)
    {
        guard intent.sessionID == context.identity.sessionID, seenEvents.insert(intent.eventID).inserted
        else
        {
            return
        }

        guard !flows.values.contains(where:
            {
                !$0.phase.isTerminal
            })
        else
        {
            appendNotice(FeatureCopy(language: state.language).busyFlow)
            return
        }

        guard !state.messages.contains(where:
            {
                $0.id == intent.messageID
            }),
            flows[intent.flowID] == nil, let source = configuration.sourceAccounts.first,
            let method = configuration.methods.first, let purpose = configuration.purposes.first
        else
        {
            return
        }

        let draft = TransferDraft(
            amount: configuration.initialAmount,
            source: source,
            recipient: intent.recipient,
            method: method,
            purpose: purpose,
            note: "")
        let snapshot = TransferSnapshot(intent: intent, revision: 0, phase: .editing(draft, nil))
        installFlow(snapshot)
        state.messages.append(ChatMessage(id: intent.messageID, date: date, revision: 0, content: .transfer(snapshot)))
    }

    func updateFlow(_ snapshot: TransferSnapshot)
    {
        guard let index = state.messages.firstIndex(where:
            {
                $0.id == snapshot.intent.messageID
            })
        else
        {
            return
        }

        state.messages[index].content = .transfer(snapshot)
        state.messages[index].revision += 1
        persist()
    }
}
