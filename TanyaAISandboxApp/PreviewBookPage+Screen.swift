import DesignKit
import SwiftUI

extension PreviewBookPage {
    var welcome: some View {
        WelcomeContent(
            title: "Hi, Lara Croft!",
            subtitle: "Temukan insight finansial untuk bantu ambil langkah lebih cerdas hari ini",
            sectionTitle: "Mulai dari sini:", actions: PreviewBookSamples.quickActions,
            onSelect: { feedback = $0.title },
            emblem: {
                PreviewArtwork(symbolName: "sparkles", tint: Color(theme.colors.accent)).clipShape(Circle())
            }
        )
    }

    var chrome: some View {
        VStack(spacing: FigmaSize.spacing32.sizeInArtwork) {
            NavigationHeader(title: "Tanya AI") {
                Button(action: { feedback = "Back callback" }, label: { headerIcon("chevron.left") })
                    .accessibilityLabel("Kembali")
            } trailing: {
                Button(
                    action: { feedback = "New session callback" },
                    label: {
                        headerIcon("ellipsis").rotationEffect(.degrees(90))
                    }
                )
                .accessibilityLabel("Percakapan baru")
            }
            DateSeparator(text: "14 Oct 2026")
            DateSeparator(text: "Hari ini 8.23 WIB")
            ScrollToLatestButton(label: "Ke pesan terbaru") { feedback = "Scroll callback" }
            Text("Status bar dan safe area dimiliki screen. Header hanya berisi title dan control slots.")
                .designFont(.caption)
        }
    }

    var statusSamples: some View {
        VStack(spacing: FigmaSize.spacing32.sizeInArtwork) {
            ActivityStatus(text: "Processing the best answer for you…")
            ActivityStatus(text: PreviewBookSamples.longText)
            LoadingStateView(label: "Loading your conversation")
        }
    }

    var artworkSamples: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.sizeInArtwork) {
            Text("Seluruh artwork di halaman ini adalah dummy. TODO penggantian ada pada PreviewArtwork.")
                .designFont(.caption)
            sample("Large emblem") {
                HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
                    emblem(tint: Color(theme.colors.accent), size: DesignKitMetrics.Size.emblem)
                    emblem(tint: .blue, size: DesignKitMetrics.Size.emblem)
                }
            }
            sample("Small emblem") {
                HStack(spacing: FigmaSize.spacing16.sizeInArtwork) {
                    emblem(tint: Color(theme.colors.accent), size: DesignKitMetrics.Size.icon)
                    emblem(tint: .blue, size: DesignKitMetrics.Size.icon)
                }
            }
            sample("Icon thumbnails") {
                SuggestionList {
                    ForEach(PreviewBookSamples.symbols, id: \.self) { symbol in
                        PreviewArtwork(symbolName: symbol, tint: Color(theme.colors.accent))
                            .frame(
                                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: DesignKitMetrics.Radius.quickAction.sizeInArtwork))
                    }
                }
            }
        }
    }

    private func emblem(tint: Color, size: CGFloat) -> some View {
        PreviewArtwork(symbolName: "sparkles", tint: tint)
            .frame(width: size.sizeInArtwork, height: size.sizeInArtwork)
            .clipShape(Circle())
    }

    private func headerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .frame(
                width: DesignKitMetrics.Size.icon.sizeInArtwork,
                height: DesignKitMetrics.Size.icon.sizeInArtwork
            )
            .foregroundColor(Color(theme.colors.accent))
            .frame(
                width: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork,
                height: DesignKitMetrics.Size.minimumTapTarget.tapTargetInArtwork)
    }
}
