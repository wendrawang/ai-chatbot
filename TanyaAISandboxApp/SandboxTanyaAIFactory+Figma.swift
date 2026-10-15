import DesignKit
import Foundation
import TanyaAI
import TanyaAITestSupport

extension SandboxTanyaAIFactory {
    static var figmaTheme: Theme {
        Theme(tokens: DefaultColorConstants(), fonts: Theme.sandbox.fonts)
    }

    static var figmaCopy: CopyCatalog {
        CopyCatalog(
            localeIdentifier: "id",
            overrides: ["chat.title": "Tanya AI", "chat.subtitle": "", "chat.placeholder": "Tanyakan apa saja..."]
        )
    }

    static var figmaWelcome: TanyaAIWelcomeConfiguration {
        TanyaAIWelcomeConfiguration(
            title: "Hi, Lara Croft!",
            subtitle: "Temukan insight finansial untuk bantu ambil langkah lebih cerdas hari ini",
            sectionTitle: "Mulai dari sini:",
            actions: [
                QuickActionData(
                    identifier: "portfolio", title: "Cek Portofolio", subtitle: "Pantau aset & performa investasimu",
                    symbolName: "chart.bar.doc.horizontal"
                ),
                QuickActionData(
                    identifier: "currency", title: "Beli Valas", subtitle: "Cek kurs dan beli mata uang asing",
                    symbolName: "dollarsign.circle"
                ),
                QuickActionData(
                    identifier: "reference", title: "Ajukan Surat Referensi",
                    subtitle: "Siapkan surat untuk kebutuhan visa",
                    symbolName: "doc.text"
                )
            ]
        )
    }

    static func figmaSession() -> MockTanyaAIChatSession {
        MockTanyaAIChatSession.figma(stepDelay: 0.15)
    }

    static var resultActions: TanyaAIChatSessionEvent {
        let payload: [String: Any] = [
            "messageIdentifier": "host-result-\(UUID().uuidString)",
            "response": [
                "blocks": [
                    [
                        "type": "actions",
                        "actions": [
                            [
                                "identifier": "result-history", "title": "Lihat riwayat transaksi",
                                "intent": "destination",
                                "target": "ocbcid://mobile?type=transaction-history",
                                "symbolName": "arrow.turn.down.right"
                            ],
                            [
                                "identifier": "result-financial", "title": "Lihat halaman finansial saya",
                                "intent": "destination",
                                "target": "ocbcid://mobile?type=portfolio", "symbolName": "arrow.turn.down.right"
                            ],
                            [
                                "identifier": "result-learn", "title": "Pelajari reksadana", "intent": "destination",
                                "target": "https://www.ocbc.id", "symbolName": "arrow.turn.down.right"
                            ]
                        ]
                    ]
                ]
            ]
        ]
        do {
            return .structuredPayload(name: "response", json: try JSONSerialization.data(withJSONObject: payload))
        } catch {
            return .failed(error)
        }
    }
}
