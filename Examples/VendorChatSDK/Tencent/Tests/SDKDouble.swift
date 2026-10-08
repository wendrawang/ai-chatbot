import Foundation

// Test-only SDK double. Never add Tests/ to the host app target.
public protocol V2TIMAdvancedMsgListener: AnyObject {
    func onRecvNewMessage(msg: V2TIMMessage)
}

public enum V2TIMMessagePriority {
    // Mirror the SDK enum spelling in this test-only module.
    // swiftlint:disable:next identifier_name
    case V2TIM_PRIORITY_NORMAL
}

public class V2TIMElem {
    public var next: V2TIMElem?
    public init() {}
    public func getNextElem() -> V2TIMElem? { next }
}

public final class V2TIMTextElem: V2TIMElem {
    public var text: String?
}

public final class V2TIMCustomElem: V2TIMElem {
    public var data: Data?
}

public final class V2TIMMessage {
    public var msgID = ""
    public var groupID: String?
    public var userID: String?
    public var isSelf = false
    public var textElem: V2TIMTextElem?
    public var customElem: V2TIMCustomElem?
    public init() {}
}

public final class V2TIMManager {
    public static let shared = V2TIMManager()
    public var loginUser: String? = "wen"
    public var listener: V2TIMAdvancedMsgListener?
    public var historyGroup: String?
    public var historyCount = 0
    public var historyLast: V2TIMMessage?
    public var historySuccess: (([V2TIMMessage]) -> Void)?
    public var historyFailure: ((Int, String) -> Void)?
    public var sendFailure: ((Int, String) -> Void)?
    public var sentMessages: [V2TIMMessage] = []
    public var sentGroups: [String?] = []
    public var sentReceivers: [String?] = []
    public var isOnlineOnly = true

    public func getLoginUser() -> String? { loginUser }

    public func addAdvancedMsgListener(listener: V2TIMAdvancedMsgListener) {
        self.listener = listener
    }

    public func removeAdvancedMsgListener(listener: V2TIMAdvancedMsgListener) {
        if self.listener === listener { self.listener = nil }
    }

    public func getGroupHistoryMessageList(
        groupID: String, count: Int, lastMsg: V2TIMMessage?,
        succ: (([V2TIMMessage]) -> Void)?, fail: ((Int, String) -> Void)?
    ) {
        historyGroup = groupID
        historyCount = count
        historyLast = lastMsg
        historySuccess = succ
        historyFailure = fail
    }

    public func createTextMessage(text: String) -> V2TIMMessage? {
        let message = V2TIMMessage()
        let element = V2TIMTextElem()
        element.text = text
        message.textElem = element
        return message
    }

    // The adapter calls the actual SDK argument labels and parameter count.
    // swiftlint:disable:next function_parameter_count
    public func sendMessage(
        message: V2TIMMessage, receiver: String?, groupID: String?,
        priority: V2TIMMessagePriority, onlineUserOnly isOnlineUserOnly: Bool,
        offlinePushInfo: Any?, progress: Any?, succ: (() -> Void)?, fail: ((Int, String) -> Void)?
    ) -> String? {
        sentMessages.append(message)
        sentGroups.append(groupID)
        sentReceivers.append(receiver)
        isOnlineOnly = isOnlineUserOnly
        sendFailure = fail
        return "sent-message"
    }

    public func reset() {
        loginUser = "wen"
        listener = nil
        historyGroup = nil
        historyCount = 0
        historyLast = nil
        historySuccess = nil
        historyFailure = nil
        sendFailure = nil
        sentMessages = []
        sentGroups = []
        sentReceivers = []
    }
}
