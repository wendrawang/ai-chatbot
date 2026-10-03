import Foundation
import TanyaAIContracts

enum MockTanyaAIAnswerFixture {
    static func events(for prompt: String, identifier: String) -> [TanyaAIChatSessionEvent]? {
        if prompt.contains("answer composition") { return events(identifier: identifier) }
        if prompt == "informasi produk" || prompt == "hubungi dukungan" { return selected(identifier: identifier) }
        return nil
    }

    static func events(identifier: String) -> [TanyaAIChatSessionEvent] {
        let parts: [[String: Any]] = [
            ["type": "radio_button", "options": [
                ["label": "Informasi produk", "value": "product"],
                ["label": "Hubungi dukungan", "value": "support"]
            ]],
            ["type": "info_card", "title": "Promo produk pilihan", "description": "Informasi promo produk.",
             "image": "https://picsum.photos/seed/product/800/320"],
            ["type": "link_button", "label": "Lihat produk", "destination_type": "deeplink",
             "target": "tanyaai-sandbox://deeplink?type=transfer"]
        ]
        do {
            let elements = try parts.map { TanyaAIChatSessionElement.custom(
                try JSONSerialization.data(withJSONObject: $0)
            ) }
            return try TanyaAIChatSessionMessage(
                identifier: "answer-\(identifier)", author: .assistant,
                elements: [.text("Pilih informasi yang ingin Anda lihat.")] + elements
            ).contentEvents
        } catch { return [.failed(error)] }
    }

    static func selected(identifier: String) -> [TanyaAIChatSessionEvent] {
        [
            .messageStarted(messageIdentifier: "reply-\(identifier)"),
            .messageDelta(messageIdentifier: "reply-\(identifier)", text: "Pilihan diterima."),
            .messageCompleted(messageIdentifier: "reply-\(identifier)")
        ]
    }
}
