import Foundation

/// The answers `DemoTanyaAITransport` replays.
///
/// Each script is the same SSE text the backend would stream, so what you see
/// in the demo is what the real contract has to produce. Schema for every
/// `content.*` event is in `docs/BUBBLE_SCHEMA.md`.
enum DemoTanyaAIScript {
    /// Routes on a keyword. Extend with whatever the demo needs to show.
    static func reply(to prompt: String) -> String {
        if prompt.contains("konfirmasi") || prompt.contains("confirm") {
            return approvalHandoff
        }
        if prompt.contains("transfer") {
            return transfer
        }
        if prompt.contains("saldo") || prompt.contains("balance") {
            return balance
        }
        return fallback
    }

    /// Text plus an action card: the deeplink hand-off from a button.
    static let transfer =
        event("response.started", ["messageIdentifier": "m1"])
        + event("text.delta", [
            "messageIdentifier": "m1",
            "text": "[bold]Transfer[/bold] bisa lewat BI-FAST atau SKN."
        ])
        + event("content.actions", [
            "messageIdentifier": "m1-card",
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
        ])
        + event("response.completed", ["messageIdentifier": "m1"])

    /// Text, an information card, and follow-up suggestions.
    static let balance =
        event("response.started", ["messageIdentifier": "m2"])
        + event("text.delta", [
            "messageIdentifier": "m2",
            "text": "Ini ringkasan [bold]saldo[/bold] kamu."
        ])
        + event("content.information", [
            "messageIdentifier": "m2-card",
            "title": "Saldo per hari ini",
            "text": "Data contoh, bukan data nasabah.",
            "items": [
                ["label": "Tabungan", "value": "Rp 12.500.000"],
                ["label": "Giro", "value": "Rp 3.200.000"]
            ]
        ])
        + event("response.suggestions", [
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
        ])
        + event("response.completed", ["messageIdentifier": "m2"])

    /// A confirmation whose Confirm button hands off instead of opening the
    /// in-feature PIN sheet. Remove `handoff` to get the PIN sheet back.
    static let approvalHandoff =
        event("response.started", ["messageIdentifier": "m3"])
        + event("text.delta", [
            "messageIdentifier": "m3",
            "text": "Konfirmasi dulu ya."
        ])
        + event("content.approval", [
            "messageIdentifier": "m3-card",
            "approvalIdentifier": "approval-1",
            "transactionIdentifier": "trx-1",
            "challengeIdentifier": "chl-1",
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
        ])
        + event("response.completed", ["messageIdentifier": "m3"])

    static let fallback =
        event("response.started", ["messageIdentifier": "m4"])
        + event("text.delta", [
            "messageIdentifier": "m4",
            "text": "Untuk demo ini coba tanya soal [bold]saldo[/bold], "
                + "[bold]transfer[/bold], atau [bold]konfirmasi[/bold]."
        ])
        + event("response.completed", ["messageIdentifier": "m4"])

    /// Ends without `response.completed`, so the typing indicator never
    /// stops. Route a keyword here to see how a truncated stream looks.
    static let neverCompletes =
        event("response.started", ["messageIdentifier": "m5"])
        + event("text.delta", [
            "messageIdentifier": "m5",
            "text": "Jawaban ini sengaja terputus"
        ])

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
