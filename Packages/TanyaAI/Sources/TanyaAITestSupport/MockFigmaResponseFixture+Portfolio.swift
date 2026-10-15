import Foundation

extension MockFigmaResponseFixture {
    static func portfolio() -> [Block] {
        [
            text(
                """
                Hi Lara, kondisi finansial tergolong sehat. Total nilai aset kamu sebesar \
                [bold]IDR 180.000.000[/bold] dengan detail:
                • [bold]Tabungan:[/bold] IDR 45.000.000 (25%)
                • [bold]Deposito:[/bold] IDR 55.000.000 (31%)
                • [bold]Reksadana Pasar Uang:[/bold] IDR 35.000.000 (17%)
                • [bold]Obligasi:[/bold] IDR 30.000.000 (17%)
                • [bold]Emas:[/bold] IDR 15.000.000 (8%)

                [bold]Evaluasi:[/bold] 56% asetmu berada di tabungan dan deposito. Portofolio kamu cenderung defensif \
                dengan peluang pertumbuhan terbatas.
                """),
            actions([
                action("Cek performa investasiku", identifier: "portfolio-performance"),
                action("Optimalkan alokasi aset", identifier: "portfolio-allocation"),
                action("Evaluasi risiko investasiku", identifier: "portfolio-risk")
            ])
        ]
    }

    static func investment() -> [Block] {
        [
            text("Investasimu menunjukkan performa positif!"),
            table(
                columns: [
                    ["title": "Produk", "widthWeight": 1.2],
                    ["title": "Nilai Saat ini\n(IDR)", "alignment": "trailing"],
                    ["title": "Keuntungan\n(IDR)", "alignment": "trailing"]
                ],
                rows: [
                    ["Reksa Dana", "35.000.000", "+1.200.000\n(+10%)"],
                    ["Reksa Dana", "30.000.000", "+900.000"],
                    ["Reksa Dana", "15.000.000", "+1.500.000"]
                ], footer: ["Total Keuntungan (IDR)", "", "+3.600.000"]),
            text(
                """
                Emas menyumbang keuntungan terbesar. Pertimbangkan diversifikasi untuk menjaga keseimbangan risiko. \
                Angka bersifat ilustratif, bukan kinerja aktual.
                """),
            actions([
                action("Bandingkan dengan pasar", identifier: "investment-market"),
                action("Optimalkan investasi yang kurang produktif", identifier: "investment-optimize")
            ])
        ]
    }

    static func optimization() -> [Block] {
        let paragraph = """
            Emas menyumbang keuntungan terbesar. Pertimbangkan diversifikasi untuk menjaga keseimbangan risiko. \
            Angka bersifat ilustratif, bukan kinerja aktual.
            """
        return [
            text(Array(repeating: paragraph, count: 10).joined(separator: "\n\n")),
            actions([action("Lihat pilihan produk", identifier: "optimization-products")])
        ]
    }

    static func products() -> [Block] {
        [
            table(
                columns: [
                    ["title": "Produk", "widthWeight": 2],
                    ["title": "Risiko", "alignment": "trailing"]
                ],
                rows: [
                    ["Batavia Dana Kas Maxima", "Rendah"],
                    ["Ashmore Dana Obligasi Unggulan Nusantara", "Menengah"],
                    ["Ashmore Dana Ekuitas Nusantara", "Tinggi"]
                ]),
            text("Periksa prospektus melalui [link]https://www.ocbc.id|OCBC[/link]."),
            ["type": "note", "text": "Tanya AI adalah AI dan bisa saja membuat kesalahan."],
            actions([action("Beli produk", identifier: "products-purchase")])
        ]
    }
}
