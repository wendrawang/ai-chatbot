import DesignKit
import SwiftUI

extension PreviewBookPage {
    var composer: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.scaledToArtwork) {
            sample("Empty / typing / send / stop") {
                MessageComposer(
                    text: $draft, placeholder: "Tanya seputar keuangan & layanan…", sendLabel: "Kirim",
                    isGenerating: isGenerating, stopLabel: "Hentikan", onStop: stop,
                    onSend: send
                )
                .accessibilityIdentifier("preview.composer.live")
                Button("Isi teks panjang") { draft = PreviewBookSamples.longText }
                    .accessibilityIdentifier("preview.composer.fill")
                Toggle("Simulasikan proses", isOn: $isGenerating)
                    .accessibilityIdentifier("preview.composer.generating")
            }
            sample("Disabled") {
                MessageComposer(
                    text: .constant("Tidak bisa dikirim"), placeholder: "Tulis pesan", sendLabel: "Kirim",
                    isEnabled: false, onSend: {})
            }
            sample("Stop tanpa handler: disabled") {
                MessageComposer(
                    text: .constant(""), placeholder: "Tulis pesan", sendLabel: "Kirim",
                    isGenerating: true, stopLabel: "Stop tidak tersedia", onSend: {})
            }
            Text("Mode stop hanya contoh callback UI. Adapter backend menentukan dukungan pembatalan.")
                .designFont(.caption)
        }
    }

    var selection: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.scaledToArtwork) {
            sample("Active → selected & readonly") {
                OptionList(
                    title: "Pilih produk:", options: PreviewBookSamples.options,
                    selectedIdentifier: selectedIdentifier, isEnabled: selectedIdentifier == nil,
                    maximumWidth: nil
                ) { option in
                    selectedIdentifier = option.identifier
                    feedback = "Dipilih: \(option.title)"
                }
                Button("Reset pilihan") { selectedIdentifier = nil }
                    .accessibilityIdentifier("preview.selection.reset")
            }
            sample("Readonly history") {
                OptionList(
                    title: nil, options: PreviewBookSamples.options, selectedIdentifier: "first",
                    isEnabled: false, maximumWidth: nil
                ) { _ in }
            }
        }
    }

    var documentSamples: some View {
        sample("Simulasi hasil persetujuan dari host") {
            ForEach(PreviewBookSamples.documents, id: \.identifier) { document in
                AcknowledgementRow(
                    title: document.title,
                    isAccepted: acceptedDocuments.contains(document.identifier)
                ) {
                    // The actual chat marks acceptance only after the host returns an accepted result.
                    acceptedDocuments.insert(document.identifier)
                    feedback = "Simulasi diterima: \(document.title)"
                }
            }
            if acceptedDocuments.count == PreviewBookSamples.documents.count {
                ActionPill(title: "Lanjut dan masukkan PIN") { feedback = "Callback otorisasi ke host" }
            }
            Button("Reset persetujuan") { acceptedDocuments = [] }
        }
    }

    private func send() {
        feedback = "Terkirim: \(draft)"
        draft = ""
    }

    private func stop() {
        isGenerating = false
        feedback = "Proses dihentikan oleh callback"
    }
}
