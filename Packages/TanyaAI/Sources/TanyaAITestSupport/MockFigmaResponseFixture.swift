import Foundation
import TanyaAIContracts

/// Transport-independent, illustrative display content for the Figma demo.
/// These examples perform no financial calculation or real transaction.
public enum MockFigmaResponseFixture {
    typealias Block = [String: Any]

    public static func events(
        for prompt: String, productTitle: String = "Manulife Dana Kas II Kelas A"
    ) -> [TanyaAIChatSessionEvent] {
        let command = prompt.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let blocks: [Block]
        switch command {
        case "cek portofolio": blocks = portfolio()
        case "cek performa investasiku": blocks = investment()
        case "optimalkan investasi yang kurang produktif": blocks = optimization()
        case "lihat pilihan produk": blocks = products()
        case "beli produk": blocks = productOptions()
        case "beli sekarang": blocks = amountInstruction()
        case "konfirmasi pembelian": blocks = documents()
        case "__transaction_success__": blocks = transactionSuccess()
        default: blocks = selectionOrAmount(prompt: prompt, productTitle: productTitle)
        }
        let activity = command == "cek performa investasiku" ? "Checking your investment…" : nil
        return response(blocks: blocks, activity: activity)
    }

    static func response(blocks: [Block], activity: String? = nil) -> [TanyaAIChatSessionEvent] {
        let identifier = "figma-\(UUID().uuidString)"
        var events: [TanyaAIChatSessionEvent] = []
        if let activity = activity {
            events.append(envelope(identifier: identifier, blocks: [["type": "activity", "text": activity]]))
        }
        events.append(envelope(identifier: identifier, blocks: blocks))
        events.append(.messageCompleted(messageIdentifier: identifier))
        return events
    }

    static func selectedProduct(in prompt: String) -> String? {
        let value = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.lowercased().contains("manulife") || value.lowercased().contains("ashmore") ? value : nil
    }

    private static func selectionOrAmount(prompt: String, productTitle: String) -> [Block] {
        if selectedProduct(in: prompt) != nil { return productMetric() }
        if prompt.trimmingCharacters(in: .whitespacesAndNewlines).first?.isNumber == true {
            return purchaseSummary(title: productTitle)
        }
        return formattedExample()
    }

    static func envelope(identifier: String, blocks: [Block]) -> TanyaAIChatSessionEvent {
        let payload: [String: Any] = ["messageIdentifier": identifier, "response": ["blocks": blocks]]
        do {
            let json = try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
            return .structuredPayload(name: "response", json: json)
        } catch {
            return .failed(error)
        }
    }

    static func text(_ value: String) -> Block { ["type": "text", "text": value] }

    static func action(
        _ title: String, identifier: String, intent: String = "prompt", target: String? = nil,
        symbolName: String? = "arrow.turn.down.right"
    ) -> Block {
        var value: Block = ["identifier": identifier, "title": title, "intent": intent, "target": target ?? title]
        if let symbolName = symbolName { value["symbolName"] = symbolName }
        return value
    }

    static func actions(_ values: [Block]) -> Block { ["type": "actions", "actions": values] }

    static func table(columns: [Block], rows: [[String]], footer: [String]? = nil) -> Block {
        var value: Block = ["columns": columns, "rows": rows.map { ["cells": $0] }]
        if let footer = footer {
            value["footer"] = [
                "cells": footer, "isEmphasized": true,
                "leadingColumnSpan": footer.count == 3 && footer[1].isEmpty ? 2 : 1
            ]
        }
        return ["type": "table", "table": value]
    }

    static func formattedExample() -> [Block] {
        [
            text(
                """
                Ini contoh [bold]jawaban native[/bold] dengan [strike]teks lama[/strike] dan \
                [color]teks berwarna|25C36B[/color].

                • [bold]Bullet pertama:[/bold] teks panjang yang membungkus dengan rapi tanpa HTML.
                • Bullet kedua memiliki [link]https://www.google.com|Buka Google[/link] di webview aplikasi.
                • [link]ocbcid://mobile?type=portfolio|Lihat portofolio[/link] membuka halaman host melalui deeplink.
                • [bold]Kode referensi contoh:[/bold] \
                DEMONSTRASIKODEREFERENSIPANJANGTANPASPASIABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890

                Seluruh nominal dalam demo ini hanya ilustrasi. Ketik “Cek Portofolio” untuk mencoba alur Figma.
                """),
            actions([action("Cek Portofolio", identifier: "demo-portfolio")])
        ]
    }
}
