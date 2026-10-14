import DesignKit
import SwiftUI

struct PreviewBookPage: View {
    @Environment(\.theme)
    var theme
    @State
    var draft = ""
    @State
    var isGenerating = false
    @State
    var selectedIdentifier: String?
    @State
    var acceptedDocuments: Set<String> = []
    @State
    var feedback = ""
    let entry: PreviewBookEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FigmaSize.spacing32.sizeInArtwork) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(FigmaSize.spacing16.sizeInArtwork)
        }
        .background(Color(theme.colors.background))
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !feedback.isEmpty {
                Text(feedback)
                    .designFont(.caption)
                    .lineLimit(2)
                    .padding(FigmaSize.spacing8.sizeInArtwork)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(theme.colors.surface))
                    .accessibilityIdentifier("preview.feedback")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("preview.page.\(entry.rawValue)")
    }

    @ViewBuilder
    private var content: some View {
        switch entry {
        case .composer: composer
        case .selection: selection
        case .text: textSamples
        case .media: mediaSamples
        case .table: tableSamples
        case .metric: metricSamples
        case .summary: summarySamples
        case .documents: documentSamples
        case .actions: actionSamples
        case .welcome: welcome
        case .chrome: chrome
        case .feedback: statusSamples
        case .artwork: artworkSamples
        }
    }

    func sample<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing8.sizeInArtwork) {
            Text(title)
                .designFont(.headline)
                .foregroundColor(Color(theme.colors.primaryText))
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
