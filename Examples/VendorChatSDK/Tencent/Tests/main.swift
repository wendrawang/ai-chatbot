import Foundation
import ImSDK_Plus_Swift
import TanyaAI

private let manager = V2TIMManager.shared
private var events: [TanyaAIChatSessionEvent] = []
private var assertions = 0

private func check(_ isCondition: Bool, _ message: String) {
    precondition(isCondition, message)
    assertions += 1
}

private func drain() {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
}

private func message(_ identifier: String, group: String?, isSelf: Bool = false) -> V2TIMMessage {
    let message = V2TIMMessage()
    message.msgID = identifier
    message.groupID = group
    message.isSelf = isSelf
    let element = V2TIMTextElem()
    element.text = "Reply \(identifier)"
    message.textElem = element
    return message
}

private func openSession(_ group: String) -> TencentChatSessionAdapter {
    manager.reset()
    events = []
    let adapter = TencentChatSessionAdapter(groupID: group)
    adapter.onEvent = { events.append($0) }
    adapter.connect()
    return adapter
}

private func completionIDs() -> [String] {
    events.compactMap {
        if case .messageCompleted(let identifier) = $0 { return identifier }
        return nil
    }
}

private func verifyHistoryAndLiveRouting() {
    let adapter = openSession("group-a")
    defer { adapter.disconnect() }
    check(manager.historyGroup == "group-a", "History must target the selected group")
    check(manager.historyCount == 20 && manager.historyLast == nil, "Initial history page")
    let live = message("live", group: "group-a")
    manager.listener?.onRecvNewMessage(msg: live)
    manager.listener?.onRecvNewMessage(msg: message("other", group: "group-b"))
    manager.listener?.onRecvNewMessage(msg: message("direct", group: nil))
    drain()
    check(events.isEmpty, "Live messages wait until history restores")
    manager.historySuccess?([
        message("self", group: "group-a", isSelf: true),
        message("agent", group: "group-a"),
        message("cross-group", group: "group-b"),
        message("bot", group: "group-a")
    ])
    drain()
    guard case .history(let history) = events.first else { fatalError("History must come first") }
    check(history.map(\.identifier) == ["bot", "agent", "self"], "Chronological, group-scoped history")
    check(history.last?.author == .customer, "Own history messages remain customer prompts")
    check(history.first?.author == .assistant, "Peer history is an assistant reply")
    check(completionIDs() == ["live"], "Only matching queued live messages render")
    manager.listener?.onRecvNewMessage(msg: live)
    manager.listener?.onRecvNewMessage(msg: message("self-live", group: "group-a", isSelf: true))
    manager.listener?.onRecvNewMessage(msg: message("agent-live", group: "group-a"))
    let tip = V2TIMMessage()
    tip.groupID = "group-a"
    tip.msgID = "group-tip"
    manager.listener?.onRecvNewMessage(msg: tip)
    drain()
    check(completionIDs() == ["live", "agent-live"], "Ignore duplicates, self echoes and group tips")
}

private func verifySendAndFailure() {
    let adapter = openSession("group-a")
    defer { adapter.disconnect() }
    manager.historyFailure?(10007, "Membership required")
    drain()
    guard case .history(let history) = events.first else { fatalError("History failure must settle loading") }
    check(history.isEmpty, "PoC falls back to empty history")
    adapter.send(text: "Hello", context: nil, requestIdentifier: "request-a")
    check(manager.sentGroups == ["group-a"], "Send to group")
    check(manager.sentReceivers.count == 1 && manager.sentReceivers[0] == nil, "No C2C receiver")
    check(!manager.isOnlineOnly, "Keep messages in group history")
    check(manager.sentMessages.first?.textElem?.text == "Hello", "Use native text element")
    manager.sendFailure?(10007, "Membership required")
    drain()
    check(events.contains { if case .failed = $0 { return true }; return false }, "Forward SDK send error")
}

private func verifyDisconnectAndBounds() {
    let adapter = openSession("group-a")
    let pendingHistory = manager.historySuccess
    for index in 0..<150 {
        manager.listener?.onRecvNewMessage(msg: message("pending-\(index)", group: "group-a"))
    }
    drain()
    manager.historySuccess?([])
    drain()
    check(completionIDs().count == 100, "Pending live buffer remains bounded")
    check(completionIDs().first == "pending-50", "Retain newest pending messages")
    for index in 0..<600 { adapter.remember("known-\(index)") }
    check(adapter.knownIdentifiers.count == 512, "Duplicate tracking remains bounded")
    adapter.disconnect()
    check(manager.listener == nil && adapter.onEvent == nil, "Release listener and callback")
    let count = events.count
    pendingHistory?([message("late", group: "group-a")])
    adapter.onRecvNewMessage(msg: message("late-live", group: "group-a"))
    adapter.send(text: "After close", context: nil, requestIdentifier: "closed")
    drain()
    check(events.count == count && manager.sentMessages.isEmpty, "No events or sends after close")
    check(adapter.knownIdentifiers.isEmpty, "Clear duplicate state on close")
}

private func verifyReleaseAfterClose() {
    weak var released: TencentChatSessionAdapter?
    autoreleasepool {
        let adapter = openSession("group-a")
        released = adapter
        adapter.disconnect()
    }
    check(released == nil, "Closed adapter releases despite stored SDK callbacks")
}

verifyHistoryAndLiveRouting()
verifySendAndFailure()
verifyDisconnectAndBounds()
verifyReleaseAfterClose()
print("Tencent group adapter: \(assertions) assertions passed (SDK double, no network).")
