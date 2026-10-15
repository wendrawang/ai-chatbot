import Foundation

extension MockFigmaResponseFixture {
    static func productOptions() -> [Block] {
        [
            [
                "type": "options",
                "options": [
                    "identifier": "product-selection", "title": "Pilih produk:",
                    "choices": [
                        ["identifier": "fund-manulife", "title": "Manulife Dana Kas II Kelas A"],
                        ["identifier": "fund-obligasi", "title": "Ashmore Dana Obligasi Unggulan Nusantara"],
                        ["identifier": "fund-ekuitas", "title": "Ashmore Dana Ekuitas Nusantara"]
                    ]
                ]
            ]
        ]
    }

    static func productMetric() -> [Block] {
        [
            [
                "type": "metric",
                "metric": [
                    "title": "NAB · Rabu, 27 Des 2026", "value": "IDR 1.783,04",
                    "change": "4,43% (IDR 76)", "isPositive": true,
                    "information": action(
                        "Informasi NAB", identifier: "metric-information", intent: "destination",
                        target: "https://www.ocbc.id", symbolName: nil
                    )
                ]
            ],
            actions([action("Beli Sekarang", identifier: "metric-buy")])
        ]
    }

    static func amountInstruction() -> [Block] {
        [text("Silakan masukan nominal dalam IDR yang kamu inginkan. Pembelian minimal IDR 10.000.")]
    }

    static func purchaseSummary(title: String) -> [Block] {
        [
            text("Silakan cek ulang, dan pastikan bahwa informasi yang kamu masukkan sudah sesuai dan benar."),
            [
                "type": "summary",
                "summary": [
                    "title": title, "subtitle": "RD Pendapatan Tetap",
                    "detail": "Konservatif · Sesuai", "symbolName": "building.columns.fill",
                    "fields": [
                        ["label": "Jumlah Pembelian", "value": "IDR 5.000.000"],
                        ["label": "Jenis Pembelian", "value": "Sekaligus"],
                        ["label": "Biaya Setiap Transaksi", "value": "IDR 3.000"],
                        ["label": "Kode Promo", "value": "OCBCULTAH83"],
                        ["label": "Total", "value": "IDR 5.003.000", "isEmphasized": true]
                    ]
                ]
            ],
            actions([
                action("Konfirmasi Pembelian", identifier: "purchase-confirm", symbolName: nil),
                action("Ubah Nominal", identifier: "purchase-edit", intent: "edit", target: "", symbolName: nil)
            ])
        ]
    }

    static func documents() -> [Block] {
        [
            text(
                """
                Pastikan kamu sudah membaca, mengerti & menyetujui ringkasan produk & layanan serta syarat & ketentuan.
                """),
            [
                "type": "documents",
                "documents": [
                    "identifier": "confirmation-demo", "continueTitle": "Lanjut dan masukkan PIN",
                    "documents": [
                        [
                            "identifier": "doc-product",
                            "title": "Ringkasan Produk dan Layanan Asuransi Reksa Dana Berjangka",
                            "destination": "ocbcid://mobile?type=document&identifier=doc-product"
                        ],
                        [
                            "identifier": "doc-terms", "title": "Syarat & Ketentuan",
                            "destination": "ocbcid://mobile?type=document&identifier=doc-terms"
                        ]
                    ]
                ]
            ]
        ]
    }

    static func transactionSuccess() -> [Block] {
        [
            text("Transaksi reksadana sebesar IDR 5.000.000 telah berhasil."),
            actions([
                action(
                    "Lihat riwayat transaksi", identifier: "result-history", intent: "destination",
                    target: "ocbcid://mobile?type=transaction-history"
                ),
                action(
                    "Lihat halaman finansial saya", identifier: "result-financial", intent: "destination",
                    target: "ocbcid://mobile?type=portfolio"
                ),
                action(
                    "Pelajari reksadana", identifier: "result-learn", intent: "destination",
                    target: "https://www.ocbc.id/id/individu/wealth-management/reksa-dana"
                )
            ])
        ]
    }
}
