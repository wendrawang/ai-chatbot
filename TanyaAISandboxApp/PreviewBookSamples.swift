import DesignKit

/// Fixtures belong to the demo app, never to production component defaults.
enum PreviewBookSamples {
    static let longText = String(repeating: "Teks panjang yang membungkus mengikuti lebar container. ", count: 4)
    static let formattedText = """
        Jawaban dengan [bold]teks tebal[/bold], [strike]teks lama[/strike], dan [color]warna khusus|25C36B[/color].

        • [bold]Tabungan:[/bold] isi bullet panjang membungkus sejajar dengan teks, bukan dengan marker.
        • [link]https://www.google.com|Buka Google[/link] diteruskan ke webview host.
        1. [link]ocbcid://mobile?type=portfolio|Lihat portofolio[/link] diteruskan ke deeplink host.
        2. Nomor kedua dengan isi yang panjang agar terlihat bagaimana hanging indent bekerja.
        """
    static let suggestions = ["Cek performa investasiku", "Optimalkan alokasi aset", "Evaluasi risiko investasiku"]
    static let symbols = [
        "briefcase.fill", "target", "chart.line.uptrend.xyaxis", "graduationcap.fill",
        "scalemass.fill", "arrow.triangle.2.circlepath", "cross.case.fill", "sos"
    ]
    static let options = [
        SelectionOption(identifier: "first", title: "Manulife Dana Kas II Kelas A"),
        SelectionOption(identifier: "second", title: "Ashmore Dana Obligasi Unggulan Nusantara"),
        SelectionOption(identifier: "third", title: "Ashmore Dana Ekuitas Nusantara"),
        SelectionOption(identifier: "fourth", title: "Batavia Dana Kas Maxima")
    ]
    static let documents = [
        SelectionOption(identifier: "product", title: "Ringkasan Produk dan Layanan Asuransi Reksa Dana Berjangka"),
        SelectionOption(identifier: "terms", title: "Syarat & Ketentuan")
    ]
    static let quickActions = [
        QuickActionData(
            identifier: "portfolio", title: "Cek Portofolio", subtitle: "Pantau aset & performa investasimu",
            symbolName: "chart.bar.doc.horizontal"),
        QuickActionData(
            identifier: "reference", title: "Ajukan Surat Referensi", subtitle: "Siapkan surat untuk visa",
            symbolName: "doc.text"),
        QuickActionData(
            identifier: "currency", title: "Beli Valas", subtitle: "Cek kurs dan beli mata uang asing",
            symbolName: "dollarsign.circle")
    ]
    static let summaryFields = [
        SummaryField(label: "Jumlah Pembelian", value: "IDR 5.000.000"),
        SummaryField(label: "Jenis Pembelian", value: "Sekaligus"),
        SummaryField(label: "Biaya Setiap Transaksi", value: "IDR 3.000"),
        SummaryField(label: "Kode Promo", value: "OCBCULTAH83"),
        SummaryField(label: "Total", value: "IDR 5.003.000", isEmphasized: true)
    ]

    static func riskTable() throws -> DataTableData {
        try DataTableData(
            columns: [
                DataTableColumn(title: "Produk", widthWeight: 2),
                DataTableColumn(title: "Risiko", alignment: .trailing)
            ],
            rows: [
                DataTableRow(cells: ["Batavia Dana Kas Maxima", "Rendah"]),
                DataTableRow(cells: ["Ashmore Dana Obligasi Unggulan Nusantara", "Menengah"]),
                DataTableRow(cells: ["Ashmore Dana Ekuitas Nusantara", "Tinggi"])
            ])
    }

    static func investmentTable() throws -> DataTableData {
        try DataTableData(
            columns: [
                DataTableColumn(title: "Produk", widthWeight: 1.4),
                DataTableColumn(title: "Nilai Saat ini (IDR)", alignment: .trailing),
                DataTableColumn(title: "Keuntungan (IDR)", alignment: .trailing)
            ],
            rows: [
                DataTableRow(cells: ["Reksa Dana", "35.000.000", "+1.200.000 (+10%)"]),
                DataTableRow(cells: ["Reksa Dana", "30.000.000", "+900.000"]),
                DataTableRow(cells: ["Reksa Dana", "15.000.000", "+1.500.000"])
            ],
            footer: DataTableRow(
                cells: ["Total Keuntungan (IDR)", "", "+3.600.000"], isEmphasized: true,
                leadingColumnSpan: 2))
    }
}
