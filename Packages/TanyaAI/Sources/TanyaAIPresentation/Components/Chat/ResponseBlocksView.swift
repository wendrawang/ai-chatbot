import DesignKit
import SwiftUI
import TanyaAIDomain

struct ResponseBlocksView: View {
    @Environment(\.theme)
    private var theme
    let payload: ResponsePayload
    let messageIdentifier: String
    let handlers: TanyaAIMessageRowHandlers

    var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing16.sizeInArtwork) {
            ForEach(payload.blocks.indices, id: \.self) { index in
                block(payload.blocks[index])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func block(_ block: ResponseBlock) -> some View {
        switch block {
        case .text(let text):
            TextBubble(text: text, isUser: false, onLink: handlers.onInlineLink)
        case .note(let text):
            TextBubble(
                text: text, isUser: false, onLink: handlers.onInlineLink,
                fontRole: .caption, foregroundColor: Color(theme.colors.secondaryText)
            )
        case .table(let data):
            DataTable(data: data)
        case .actions(let actions):
            actionList(actions)
        case .options(let options):
            OptionList(
                title: options.title,
                options: options.choices.map { SelectionOption(identifier: $0.identifier, title: $0.title) },
                selectedIdentifier: options.selectedIdentifier,
                isEnabled: !options.isReadOnly && !payload.isReadOnly && handlers.isSendEnabled,
                maximumWidth: nil,
                onSelect: { handlers.onResponseOption(messageIdentifier, options.identifier, $0.identifier) }
            )
        case .metric(let metric):
            metricSummary(metric)
        case .summary(let summary):
            SummaryCard(fields: summary.fields) {
                ItemHeader(
                    title: summary.title, subtitle: summary.subtitle,
                    detail: summary.detail, symbolName: summary.symbolName
                )
            }
        case .documents(let documents):
            documentList(documents)
        case .activity(let text):
            ActivityStatus(text: text)
        }
    }

    private func actionList(_ actions: [ResponseAction]) -> some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing8.sizeInArtwork) {
            ForEach(actions, id: \.identifier) { action in
                if action.intent == .destination || !payload.isReadOnly {
                    ActionPill(
                        title: action.title, symbolName: action.symbolName,
                        isEnabled: action.intent != .prompt || handlers.isSendEnabled
                    ) {
                        handlers.onResponseAction(messageIdentifier, action)
                    }
                    .accessibilityIdentifier("response.action.\(action.identifier)")
                }
            }
        }
    }

    private func metricSummary(_ metric: ResponseMetric) -> some View {
        MetricSummary(
            title: metric.title, value: metric.value, change: metric.change,
            isPositive: metric.isPositive ?? true,
            infoLabel: metric.information?.title,
            onInfo: metric.information.map { action in
                { handlers.onResponseAction(messageIdentifier, action) }
            }
        )
    }

    private func documentList(_ documents: ResponseDocuments) -> some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing8.sizeInArtwork) {
            ForEach(documents.documents, id: \.identifier) { document in
                AcknowledgementRow(
                    title: document.title,
                    isAccepted: documents.acceptedIdentifiers.contains(document.identifier),
                    isEnabled: handlers.isHostFlowEnabled && !documents.isAuthorized
                ) {
                    handlers.onResponseDocument(messageIdentifier, documents.identifier, document.identifier)
                }
                .accessibilityIdentifier("document.\(document.identifier)")
            }
            if documents.isReady && !documents.isAuthorized {
                ActionPill(title: documents.continueTitle, isEnabled: handlers.isHostFlowEnabled) {
                    handlers.onResponseAuthorize(messageIdentifier, documents.identifier, documents.continueTitle)
                }
                .accessibilityIdentifier("documents.authorize")
            }
        }
    }
}
