import DesignKit
import SwiftUI

extension PreviewBookPage {
    var textSamples: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.scaledToArtwork) {
            sample("Outgoing: short & multiline") {
                TextBubble(text: "Cek Portofolio", isUser: true).frame(maxWidth: .infinity, alignment: .trailing)
                TextBubble(text: PreviewBookSamples.longText, isUser: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            sample("Incoming: native formatting, bullets & links") {
                TextBubble(text: PreviewBookSamples.formattedText, isUser: false) { url in
                    feedback = "Link callback: \(url.absoluteString)"
                }
            }
            sample("Caption / disclaimer") {
                TextBubble(
                    text: "Informasi ini bersifat ilustratif.", isUser: false, fontRole: .caption,
                    foregroundColor: Color(theme.colors.secondaryText))
            }
        }
    }

    var mediaSamples: some View {
        sample("Artwork slot + wrapping title") {
            MediaCard(title: "Bonus bunga tabungan", subtitle: "Jalani misinya, dapatkan bonus bunga tabungan.") {
                PreviewArtwork(symbolName: "gift.fill", tint: Color(theme.colors.accent))
            }
            MediaCard(title: PreviewBookSamples.longText, subtitle: PreviewBookSamples.longText) {
                PreviewArtwork(symbolName: "photo", tint: .blue)
            }
        }
    }

    var tableSamples: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.scaledToArtwork) {
            sample("Two columns: product & risk") {
                if let data = try? PreviewBookSamples.riskTable() { DataTable(data: data) }
            }
            sample("Three columns + total") {
                if let data = try? PreviewBookSamples.investmentTable() { DataTable(data: data) }
            }
            Text("Maksimal tiga kolom. Ukuran font aksesibilitas memakai label/value per baris.")
                .designFont(.caption)
        }
    }

    var metricSamples: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.scaledToArtwork) {
            MetricSummary(
                title: "NAB · Rabu, 27 Des 2026", value: "IDR 1.783,04", change: "↗ 4,43% (IDR 76)",
                infoLabel: "Informasi NAB", onInfo: { feedback = "Callback informasi" })
            MetricSummary(title: "Perubahan negatif", value: "IDR 1.600,00", change: "−2,30%", isPositive: false)
            MetricSummary(
                title: PreviewBookSamples.longText, value: "IDR 123.456.789.012,34",
                change: "+12.345.678,90 (+12,34%)")
        }
    }

    var summarySamples: some View {
        sample("Item header + fields + total") {
            SummaryCard(fields: PreviewBookSamples.summaryFields) {
                ItemHeader(
                    title: "Manulife Dana Kas II Kelas A", subtitle: "RD Pendapatan Tetap",
                    detail: "Konservatif · Sesuai", symbolName: "building.columns.fill")
            }
            SummaryCard(fields: [SummaryField(label: PreviewBookSamples.longText, value: "123.456.789.012,34")]) {
                ItemHeader(title: PreviewBookSamples.longText, subtitle: "Judul panjang", symbolName: "doc.text")
            }
        }
    }
}
