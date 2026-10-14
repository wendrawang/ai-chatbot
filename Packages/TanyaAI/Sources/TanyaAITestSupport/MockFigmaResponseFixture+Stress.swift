import Foundation

extension MockFigmaResponseFixture {
    static func stressResponse(for command: String) -> [Block]? {
        switch command {
        case "stress table": return stressTable()
        case "stress metric": return stressMetric()
        case "stress summary": return stressSummary()
        case "stress options": return stressOptions()
        default: return nil
        }
    }

    static func stressTable() -> [Block] {
        [
            table(
                columns: [
                    ["title": "Nama produk investasi dengan judul panjang", "widthWeight": 1.4],
                    ["title": "Nilai saat ini (IDR)", "alignment": "trailing"],
                    ["title": "Keuntungan (IDR)", "alignment": "trailing"]
                ],
                rows: [
                    [
                        "Reksa Dana Pendapatan Tetap dengan nama sangat panjang", "123.456.789.012",
                        "+12.345.678 (+12,34%)"
                    ],
                    ["ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", "1.234.567.890", "−9.876.543 (−12,34%)"],
                    ["Reksa Dana Pasar Uang", "35.000.000", "+1.200.000 (+10%)"]
                ], footer: ["Total keuntungan seluruh produk (IDR)", "", "+3.600.000"]
            ), text("Akhir tabel. Semua kolom dan baris tetap dapat dibaca tanpa scroll horizontal.")
        ]
    }

    static func stressMetric() -> [Block] {
        [
            [
                "type": "metric",
                "metric": [
                    "title": "Nilai bersih per unit · tanggal valuasi yang panjang", "value": "IDR 123.456.789.012,34",
                    "change": "12,34% (IDR 1.234.567.890)", "isPositive": false,
                    "information": action(
                        "Informasi nilai", identifier: "stress-info", intent: "destination",
                        target: "https://www.ocbc.id", symbolName: nil)
                ]
            ], text("Akhir metrik.")
        ]
    }

    static func stressSummary() -> [Block] {
        let name = "Produk dengan nama yang sangat panjang dan keterangan tambahan di beberapa baris"
        return [
            [
                "type": "summary",
                "summary": [
                    "title": name, "subtitle": name, "detail": "Kategori serta tingkat risiko untuk contoh tampilan",
                    "symbolName": "building.columns.fill",
                    "fields": [
                        ["label": "Jumlah pembelian dalam mata uang pilihan", "value": "IDR 123.456.789.012,34"],
                        [
                            "label": "Kode referensi tanpa spasi",
                            "value": "ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234567890"
                        ],
                        ["label": "Total seluruh transaksi", "value": "IDR 123.456.789.012,34", "isEmphasized": true]
                    ]
                ]
            ], text("Akhir ringkasan.")
        ]
    }

    static func stressOptions() -> [Block] {
        [
            [
                "type": "options",
                "options": [
                    "identifier": "stress-options", "title": "Pilihan produk dengan judul yang panjang",
                    "choices": [
                        [
                            "identifier": "stress-first",
                            "title": "Pilihan dengan nama panjang dan deskripsi lebih dari satu baris"
                        ],
                        ["identifier": "stress-second", "title": "ABCDEFGHIJKLMNOPQRSTUVWXYZ12345678901234567890"],
                        ["identifier": "stress-third", "title": "Pilihan ketiga tetap terlihat sebagai riwayat"]
                    ], "selectedIdentifier": "stress-first", "isReadOnly": true
                ]
            ],
            [
                "type": "documents",
                "documents": [
                    "identifier": "stress-documents", "continueTitle": "Lanjutkan",
                    "documents": [
                        ["identifier": "stress-doc", "title": "Dokumen ringkasan dengan nama sangat panjang"]
                    ],
                    "acceptedIdentifiers": ["stress-doc"]
                ]
            ],
            actions([
                action(
                    "Aksi dengan judul panjang yang perlu membungkus dengan rapi",
                    identifier: "stress-action", intent: "destination", target: "https://www.ocbc.id")
            ])
        ]
    }
}
