import Foundation
import ImSDK_Plus_Swift
import TanyaAI

/// One instance per Tanya AI presentation; SDK login remains app-wide.
final class TencentChatSessionAdapter: TanyaAIChatSession {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)?

    private let botUserID: String
    private let manager = V2TIMManager.shared
    private var isActive = false
    private var isLoadingHistory = false
    private var pendingMessages: [V2TIMMessage] = []
    private var knownIdentifiers = Set<String>()

    init(botUserID: String) {
        self.botUserID = botUserID
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
        isActive = true
        isLoadingHistory = true
        manager.addAdvancedMsgListener(listener: self)
        manager.getC2CHistoryMessageList(
            userID: botUserID,
            count: 20,
            lastMsg: nil,
            succ: { [weak self] messages in
                DispatchQueue.main.async { self?.finishHistory(messages) }
            },
            fail: { [weak self] _, _ in
                DispatchQueue.main.async {
                    self?.finishHistory([])
                }
            }
        )
    }

    func send(text: String, context: TanyaAIContext?, requestIdentifier: String) {
        guard isActive else { return }
        guard let message = manager.createTextMessage(text: text) else {
            onEvent?(.failed(TencentChatError.messageCreationFailed))
            return
        }
        // A backend must define how context/requestIdentifier are carried.
        // Do not insert either into visible message text.
        _ = manager.sendMessage(
            message: message,
            receiver: botUserID,
            groupID: nil,
            priority: .V2TIM_PRIORITY_NORMAL,
            onlineUserOnly: false,
            offlinePushInfo: nil,
            progress: nil,
            succ: nil,
            fail: { [weak self] code, description in
                DispatchQueue.main.async {
                    self?.onEvent?(.failed(TencentChatError.sdk(code: Int(code), message: description)))
                }
            }
        )
    }

    func disconnect() {
        guard isActive else { return }
        isActive = false
        manager.removeAdvancedMsgListener(listener: self)
        pendingMessages.removeAll()
        knownIdentifiers.removeAll()
        onEvent = nil
    }

    private func finishHistory(_ messages: [V2TIMMessage]) {
        guard isActive else { return }
        let ordered = messages.sorted { $0.timestamp < $1.timestamp }
        let history = ordered.compactMap { message -> TanyaAIChatSessionMessage? in
            guard message.userID == botUserID,
                  let text = message.textElem?.text,
                  !text.isEmpty else { return nil }
            knownIdentifiers.insert(message.msgID)
            return TanyaAIChatSessionMessage(
                identifier: message.msgID,
                author: message.isSelf ? .customer : .assistant,
                text: text
            )
        }
        onEvent?(.history(history))
        isLoadingHistory = false
        onEvent?(.connected)
        let pending = pendingMessages
        pendingMessages.removeAll()
        pending.forEach(handleIncoming)
    }

    private func handleIncoming(_ message: V2TIMMessage) {
        guard isActive, message.userID == botUserID,
              !message.isSelf, !knownIdentifiers.contains(message.msgID),
              let text = message.textElem?.text, !text.isEmpty else { return }
        knownIdentifiers.insert(message.msgID)
        onEvent?(.messageStarted(messageIdentifier: message.msgID))
        onEvent?(.messageDelta(messageIdentifier: message.msgID, text: text))
        onEvent?(.messageCompleted(messageIdentifier: message.msgID))
    }
}

extension TencentChatSessionAdapter: V2TIMAdvancedMsgListener {
    func onRecvNewMessage(msg: V2TIMMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isActive, msg.userID == self.botUserID else { return }
            if self.isLoadingHistory {
                self.pendingMessages.append(msg)
            } else {
                self.handleIncoming(msg)
            }
        }
    }
}
