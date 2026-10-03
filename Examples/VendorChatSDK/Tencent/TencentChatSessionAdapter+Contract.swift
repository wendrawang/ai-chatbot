import Foundation
import ImSDK_Plus_Swift
import TanyaAI

extension TencentChatSessionAdapter {
    /// SDK REST `MsgBody` becomes an element chain, not a JSON text message.
    func contractMessage(_ message: V2TIMMessage) -> TanyaAIChatSessionMessage? {
        var elements: [TanyaAIChatSessionElement] = []
        var element: V2TIMElem? = message.textElem
        if element == nil { element = message.customElem }
        var count = 0
        while let current = element, count < 64 {
            if let text = current as? V2TIMTextElem, let value = text.text {
                elements.append(.text(value))
            } else if let custom = current as? V2TIMCustomElem, let data = custom.data {
                elements.append(.custom(data))
            } else {
                elements.append(.custom(Data(#"{"type":"unsupported"}"#.utf8)))
            }
            count += 1
            element = current.getNextElem()
        }
        guard !elements.isEmpty else { return nil }
        do {
            guard element == nil else { throw CocoaError(.coderReadCorrupt) }
            return try TanyaAIChatSessionMessage(
                identifier: message.msgID,
                author: message.isSelf ? .customer : .assistant,
                elements: elements
            )
        } catch {
            // Preserve a malformed custom message as a safe unsupported card.
            let json = try? JSONSerialization.data(withJSONObject: [
                "messageIdentifier": message.msgID, "elements": [["type": "unsupported"]]
            ])
            return TanyaAIChatSessionMessage(
                identifier: message.msgID, author: message.isSelf ? .customer : .assistant,
                text: "", structuredName: "components", structuredJSON: json
            )
        }
    }

    /// Bounded duplicate suppression; the SDK's stored history remains authoritative.
    func remember(_ identifier: String) {
        guard knownIdentifiers.insert(identifier).inserted else { return }
        orderedIdentifiers.append(identifier)
        if orderedIdentifiers.count > 512 {
            knownIdentifiers.remove(orderedIdentifiers.removeFirst())
        }
    }
}
