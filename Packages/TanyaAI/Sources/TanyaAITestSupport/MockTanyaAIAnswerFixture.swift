import Foundation
import TanyaAIContracts

enum MockTanyaAIAnswerFixture {
    static func events(for prompt: String, identifier: String) -> [TanyaAIChatSessionEvent]? {
        if prompt.contains("answer composition") { return events(identifier: identifier) }
        if prompt == "informasi produk" || prompt == "hubungi dukungan" { return selected(identifier: identifier) }
        return nil
    }

    static func events(identifier: String) -> [TanyaAIChatSessionEvent] {
        let payload: [String: Any] = [
            "messageIdentifier": "answer-\(identifier)",
            "text": "Pilih informasi yang ingin Anda lihat.",
            "options": [
                ["identifier": "product", "title": "Informasi produk"],
                ["identifier": "support", "title": "Hubungi dukungan"]
            ],
            "image": [
                "imageURL": "https://picsum.photos/seed/product/800/320",
                "caption": "Promo produk pilihan",
                "aspectRatio": 2.5,
                "accessibilityText": "Ilustrasi promo produk"
            ],
            "actions": [[
                "title": "Lihat produk",
                "action": ["identifier": "product", "deeplink": "tanyaai-sandbox://deeplink?type=transfer"]
            ]]
        ]
        return [
            .messageStarted(messageIdentifier: "answer-\(identifier)"),
            MockTanyaAIResponseFixture.event("answer", payload),
            .messageCompleted(messageIdentifier: "answer-\(identifier)")
        ]
    }

    static func selected(identifier: String) -> [TanyaAIChatSessionEvent] {
        [
            .messageStarted(messageIdentifier: "reply-\(identifier)"),
            .messageDelta(messageIdentifier: "reply-\(identifier)", text: "Pilihan diterima."),
            .messageCompleted(messageIdentifier: "reply-\(identifier)")
        ]
    }
}
