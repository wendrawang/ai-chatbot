import Foundation

/// The answers `DemoTanyaAITransport` replays.
///
/// Each script is the same SSE text the backend would stream, so what you see
/// in the demo is what the real contract has to produce. Schema for every
/// `content.*` event is in `docs/BUBBLE_SCHEMA.md`.
enum DemoTanyaAIScript {
    /// Routes on a keyword. Extend with whatever the demo needs to show.
    ///
    /// Every reply gets a fresh identifier. Reusing one makes the next answer
    /// overwrite the previous bubble instead of adding to the conversation -
    /// and for a confirmation the customer already cancelled, that reads as
    /// the rejected bubble reopening itself.
    static func reply(to prompt: String) -> String {
        let turn = String(UUID().uuidString.prefix(8))

        if prompt.contains("konfirmasi") || prompt.contains("confirm") {
            return approvalHandoff(turn)
        }
        if prompt.contains("transfer") {
            return transfer(turn)
        }
        if prompt.contains("saldo") || prompt.contains("balance") {
            return balance(turn)
        }
        return fallback(turn)
    }

    /// Text plus an action card: the deeplink hand-off from a button.
    static func transfer(_ turn: String) -> String {
        [
            started(turn),
            event("text.delta", [
                "messageIdentifier": "text-\(turn)",
                "text": "[bold]Transfer[/bold] bisa lewat BI-FAST atau SKN."
            ]),
            event("content.actions", [
                "messageIdentifier": "card-\(turn)",
                "title": "Lanjut di aplikasi",
                "detail": "Membuka halaman yang sudah ada.",
                "actions": [
                    [
                        "title": "Buka form transfer",
                        "style": "primary",
                        "action": [
                            "identifier": "open-transfer",
                            "deeplink":
                                "ocbcid://mobile?type=transfer&amount=1250000"
                        ]
                    ],
                    [
                        "title": "Lihat riwayat",
                        "style": "secondary",
                        "action": [
                            "identifier": "open-history",
                            "deeplink": "ocbcid://mobile?type=history"
                        ]
                    ]
                ]
            ]),
            completed(turn)
        ].joined()
    }

    /// Text, an information card, and follow-up suggestions.
    static func balance(_ turn: String) -> String {
        [
            started(turn),
            event("text.delta", [
                "messageIdentifier": "text-\(turn)",
                "text": "Ini ringkasan [bold]saldo[/bold] kamu."
            ]),
            event("content.information", [
                "messageIdentifier": "card-\(turn)",
                "title": "Saldo per hari ini",
                "text": "Data contoh, bukan data nasabah.",
                "items": [
                    ["label": "Tabungan", "value": "Rp 12.500.000"],
                    ["label": "Giro", "value": "Rp 3.200.000"]
                ]
            ]),
            event("response.suggestions", [
                "suggestions": [
                    [
                        "identifier": "history",
                        "title": "Riwayat",
                        "prompt": "Lihat riwayat transaksi"
                    ],
                    [
                        "identifier": "transfer",
                        "title": "Transfer",
                        "prompt": "Saya mau transfer"
                    ]
                ]
            ]),
            completed(turn)
        ].joined()
    }

    /// A confirmation whose Confirm button hands off instead of opening the
    /// in-feature PIN sheet. Remove `handoff` to get the PIN sheet back.
    static func approvalHandoff(_ turn: String) -> String {
        [
            started(turn),
            event("text.delta", [
                "messageIdentifier": "text-\(turn)",
                "text": "Konfirmasi dulu ya."
            ]),
            event("content.approval", [
                "messageIdentifier": "card-\(turn)",
                "approvalIdentifier": "approval-\(turn)",
                "transactionIdentifier": "trx-\(turn)",
                "challengeIdentifier": "chl-\(turn)",
                "kind": "transfer",
                "title": "Konfirmasi transfer",
                "summary": [
                    ["label": "Ke", "value": "Budi Santoso"],
                    ["label": "Nominal", "value": "Rp 1.250.000"]
                ],
                "notice": "Otorisasi selesai di halaman existing.",
                "expiresAt": "2099-01-01T00:00:00Z",
                "handoff": [
                    "identifier": "handoff-transfer",
                    "deeplink": "ocbcid://mobile?type=transfer&amount=1250000"
                ]
            ]),
            completed(turn)
        ].joined()
    }

    static func fallback(_ turn: String) -> String {
        [
            started(turn),
            event("text.delta", [
                "messageIdentifier": "text-\(turn)",
                "text": "Untuk demo ini coba tanya soal [bold]saldo[/bold], "
                    + "[bold]transfer[/bold], atau [bold]konfirmasi[/bold]."
            ]),
            completed(turn)
        ].joined()
    }

    /// Ends without `response.completed`, so the typing indicator never
    /// stops. Route a keyword here to see how a truncated stream looks.
    static func neverCompletes(_ turn: String) -> String {
        [
            started(turn),
            event("text.delta", [
                "messageIdentifier": "text-\(turn)",
                "text": "Jawaban ini sengaja terputus"
            ])
        ].joined()
    }

    // MARK: - Building blocks

    private static func started(_ turn: String) -> String {
        event("response.started", ["messageIdentifier": "text-\(turn)"])
    }

    private static func completed(_ turn: String) -> String {
        event("response.completed", ["messageIdentifier": "text-\(turn)"])
    }

    /// One SSE event: `event: name` then `data: {...}`, ended by a blank line.
    static func event(_ name: String, _ payload: [String: Any]) -> String {
        let data = (try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )) ?? Data()
        let json = String(data: data, encoding: .utf8) ?? "{}"
        return "event: \(name)\ndata: \(json)\n\n"
    }
}
