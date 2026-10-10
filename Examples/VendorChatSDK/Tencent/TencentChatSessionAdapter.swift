import Foundation
import ImSDK_Plus_Swift
import TanyaAI

/// One instance per group presentation; membership is provisioned by the host backend.
final class TencentChatSessionAdapter: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let groupID: String
    private let manager = V2TIMManager.shared
    private var generation = 0
    private var isActive = false
    private var isLoadingHistory = false
    private var pendingMessages: [V2TIMMessage] = []
    var knownIdentifiers = Set<String>()
    var orderedIdentifiers: [String] = []

    init(groupID: String) {
        self.groupID = groupID
    }

    deinit {
        disconnect()
    }

    func connect() {
        guard !isActive else { return }
        guard manager.getLoginUser() != nil else {
            onEvent?(.failed(TencentChatError.notLoggedIn))
            return
        }
        generation += 1
        let epoch = generation
        knownIdentifiers.removeAll()
        orderedIdentifiers.removeAll()
        isActive = true
        isLoadingHistory = true
        manager.addAdvancedMsgListener(listener: self)
        manager.getGroupHistoryMessageList(
            groupID: groupID,
            count: 20,
            lastMsg: nil,
            succ: { [weak self] messages in
                DispatchQueue.main.async {
                    guard let self, self.generation == epoch else { return }
                    self.finishHistory(messages)
                }
            },
            fail: { [weak self] code, description in
                DispatchQueue.main.async {
                    guard let self, self.generation == epoch else { return }
                    self.onEvent?(.historyFailed(TencentChatError.sdk(code: Int(code), message: description)))
                    self.finishHistory(nil)
                }
            }
        )
    }

    @discardableResult
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) -> String? {
        guard isActive else { return nil }
        let epoch = generation
        guard let message = manager.createTextMessage(text: text) else {
            onEvent?(.sendFailed(requestIdentifier: requestIdentifier, error: TencentChatError.messageCreationFailed))
            return nil
        }
        // The request ID identifies this SDK submission, not a future bot reply.
        return manager.sendMessage(
            message: message,
            receiver: nil,
            groupID: groupID,
            priority: .V2TIM_PRIORITY_NORMAL,
            onlineUserOnly: false,
            offlinePushInfo: nil,
            progress: nil,
            succ: { [weak self] in
                DispatchQueue.main.async {
                    guard let self, self.isActive, self.generation == epoch else { return }
                    self.onEvent?(
                        .sendSucceeded(
                            requestIdentifier: requestIdentifier, messageIdentifier: message.msgID
                        ))
                }
            },
            fail: { [weak self] code, description in
                DispatchQueue.main.async {
                    guard let self, self.isActive, self.generation == epoch else { return }
                    self.onEvent?(
                        .sendFailed(
                            requestIdentifier: requestIdentifier,
                            error: TencentChatError.sdk(code: Int(code), message: description)
                        ))
                }
            }
        )
    }

    func disconnect() {
        guard isActive else { return }
        generation += 1
        isActive = false
        manager.removeAdvancedMsgListener(listener: self)
        pendingMessages.removeAll()
        knownIdentifiers.removeAll()
        orderedIdentifiers.removeAll()
        onEvent = nil
    }

    private func finishHistory(_ messages: [V2TIMMessage]?) {
        guard isActive else { return }
        // The SDK returns newest first; preserve its order even when timestamps are equal.
        let ordered = Array((messages ?? []).reversed())
        let history = ordered.compactMap { message -> TanyaAIChatSessionMessage? in
            guard message.groupID == groupID else { return nil }
            remember(message.msgID)
            return contractMessage(message)
        }
        if messages != nil { onEvent?(.history(history)) }
        isLoadingHistory = false
        onEvent?(.connected)
        let pending = pendingMessages
        pendingMessages.removeAll()
        pending.forEach(handleIncoming)
    }

    private func handleIncoming(_ message: V2TIMMessage) {
        guard isActive, message.groupID == groupID,
            !message.isSelf, !knownIdentifiers.contains(message.msgID)
        else { return }
        remember(message.msgID)
        contractMessage(message)?.contentEvents.forEach { onEvent?($0) }
    }
}

extension TencentChatSessionAdapter: V2TIMAdvancedMsgListener {
    func onRecvNewMessage(msg: V2TIMMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isActive, msg.groupID == self.groupID else { return }
            if self.isLoadingHistory {
                if self.pendingMessages.count >= 100 { self.pendingMessages.removeFirst() }
                self.pendingMessages.append(msg)
            } else {
                self.handleIncoming(msg)
            }
        }
    }
}
