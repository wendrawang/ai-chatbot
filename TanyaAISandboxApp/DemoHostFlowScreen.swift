import DesignKit
import SwiftUI
import TanyaAI

struct DemoHostDocumentScreen: View {
    @Environment(\.theme)
    private var theme
    @State
    private var isAccepted = false
    @State
    private var isCompleting = false
    let title: String
    let onFinish: (TanyaAIHostFlowResult) -> Void

    var body: some View {
        VStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
            DemoHostHeader(title: title) { finish(.cancelled) }
            ScrollView {
                Text(DemoHostCopy.documentBody)
                    .designFont(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(FigmaSize.spacing16.sizeInArtwork)
            }
            AcknowledgementRow(title: DemoHostCopy.acceptance, isAccepted: isAccepted, isEnabled: !isCompleting) {
                isAccepted.toggle()
            }
            .accessibilityIdentifier("sandbox.document.accept")
            Button("Lanjut") { finish(.accepted) }
                .designFont(.button)
                .foregroundColor(.white)
                .padding(FigmaSize.spacing16.sizeInArtwork)
                .frame(maxWidth: .infinity)
                .background(Color(theme.colors.accent))
                .cornerRadius(DesignKitMetrics.Radius.composer.sizeInArtwork)
                .disabled(!isAccepted || isCompleting)
                .accessibilityIdentifier("sandbox.document.continue")
        }
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .padding(.bottom, FigmaSize.spacing16.sizeInArtwork)
        .background(Color.white)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sandbox.document.screen")
    }

    private func finish(_ status: TanyaAIHostFlowResult.Status) {
        guard !isCompleting else { return }
        isCompleting = true
        onFinish(TanyaAIHostFlowResult(status: status))
    }
}

struct DemoHostPINScreen: View {
    @Environment(\.theme)
    private var theme
    @State
    private var digitCount = 0
    @State
    private var isCompleting = false
    let onFinish: (TanyaAIHostFlowResult) -> Void

    var body: some View {
        VStack(spacing: FigmaSize.spacing32.sizeInArtwork) {
            DemoHostHeader(title: "PIN Transaksi") { finish(.cancelled) }
            Text("Masukkan 6 digit PIN Transaksi").designFont(.body)
            Spacer(minLength: FigmaSize.spacing16.sizeInArtwork)
            Image(systemName: "lock").designFont(.title).accessibilityHidden(true)
            HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(Color(index < digitCount ? theme.colors.accent : theme.colors.secondaryText))
                        .frame(
                            width: DesignKitMetrics.Size.secureDigit.sizeInArtwork,
                            height: DesignKitMetrics.Size.secureDigit.sizeInArtwork
                        )
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Jumlah digit")
            .accessibilityValue("\(digitCount) dari 6")
            .accessibilityIdentifier("sandbox.pin.count")
            NumericKeypad(
                onDigit: { _ in enterDigit() }, onDelete: { digitCount = max(0, digitCount - 1) },
                isDisabled: isCompleting
            )
            Text("Demo host · tidak menjalankan transaksi")
                .designFont(.caption)
                .foregroundColor(.secondary)
            Spacer(minLength: FigmaSize.spacing16.sizeInArtwork)
        }
        .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
        .background(Color.white)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sandbox.pin.screen")
    }

    private func enterDigit() {
        guard !isCompleting, digitCount < 6 else { return }
        digitCount += 1
        if digitCount == 6 { finish(.completed) }
    }

    private func finish(_ status: TanyaAIHostFlowResult.Status) {
        guard !isCompleting else { return }
        isCompleting = true
        digitCount = 0
        onFinish(TanyaAIHostFlowResult(status: status, message: status == .completed ? DemoHostCopy.success : nil))
    }
}

struct DemoHostHeader: View {
    @Environment(\.theme)
    private var theme
    let title: String
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: FigmaSize.spacing8.sizeInArtwork) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .designFont(.headline)
                    .foregroundColor(Color(theme.colors.accent))
                    .frame(
                        width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                        height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                    )
            }
            .accessibilityLabel("Kembali ke chat")
            .accessibilityIdentifier("sandbox.host.close")
            Text(title).designFont(.headline).frame(maxWidth: .infinity)
            Color.clear.frame(
                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
            )
        }
        .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
    }
}

private enum DemoHostCopy {
    static let success = "Transaksi reksadana sebesar IDR 5.000.000 telah berhasil."
    static let acceptance = "Saya telah membaca, memahami, dan menyetujui dokumen contoh ini."
    static let documentBody = """
        Dokumen contoh untuk menguji bridge halaman existing host.

        Layanan dan informasi pada halaman ini adalah dummy. Tidak ada persetujuan hukum atau transaksi yang dijalankan.

        RINGKASAN INFORMASI
        Baca informasi produk, manfaat, risiko, biaya, serta syarat dan ketentuan pada halaman host yang sebenarnya.

        Pilih persetujuan di bawah lalu lanjutkan untuk mengembalikan hasil ke percakapan yang sama.
        """
}
