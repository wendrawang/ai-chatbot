import Foundation

extension MockFigmaResponseFixture {
    static func componentExample() -> [Block] {
        var redirect = action(
            "Buka informasi produk", identifier: "components-link", intent: "destination",
            target: "https://www.google.com", symbolName: nil)
        redirect["presentation"] = "link"
        var optimize = action(
            "Optimize now", identifier: "components-optimize",
            target: "Optimalkan investasi yang kurang produktif", symbolName: "sparkles")
        optimize["presentation"] = "filled"
        return [
            text(
                "[bold]Pilihan untukmu[/bold]\n• Informasi dapat berisi teks, gambar, dan action terpisah.\n"
                    + "• [strike]Informasi lama[/strike] diganti [color]informasi baru|25C36B[/color]."),
            [
                "type": "media",
                "media": [
                    "title": "Bonus bunga tabungan",
                    "subtitle":
                        "Jalani misinya, dapatkan bonus bunga tabungan.", "symbolName": "gift.fill"
                ]
            ],
            actions([redirect, optimize]),
            [
                "type": "suggestions",
                "actions": [
                    action("Cek Portofolio", identifier: "components-portfolio"),
                    action("Lihat pilihan produk", identifier: "components-products"),
                    action("Cek performa investasiku", identifier: "components-performance")
                ]
            ]
        ]
    }
}
