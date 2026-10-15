import DesignKit
import SwiftUI

/// Demo-only catalog: production DesignKit contains no fixtures or preview state.
struct PreviewBookScreen: View {
    var body: some View {
        NavigationView {
            List {
                category("Input & selection", entries: [.composer, .selection])
                category("Content", entries: [.text, .media, .table, .metric, .summary, .documents])
                category("Actions", entries: [.actions])
                category("Screen composition", entries: [.welcome, .chrome, .feedback, .artwork])
            }
            .navigationTitle("PreviewBook")
            .accessibilityIdentifier("preview.catalog")
        }
        .navigationViewStyle(.stack)
        .theme(Theme(tokens: DefaultColorConstants(), fonts: Theme.sandbox.fonts))
        .copyCatalog(CopyCatalog(localeIdentifier: "id"))
    }

    private func category(_ title: String, entries: [PreviewBookEntry]) -> some View {
        Section(header: Text(title)) {
            ForEach(entries, id: \.rawValue) { entry in
                NavigationLink(destination: PreviewBookPage(entry: entry)) {
                    Text(entry.title)
                }
                .accessibilityIdentifier("preview.component.\(entry.rawValue)")
            }
        }
    }
}

enum PreviewBookEntry: String {
    case composer, selection, text, media, table, metric, summary, documents
    case actions, welcome, chrome, feedback, artwork

    var title: String {
        switch self {
        case .composer: return "MessageComposer"
        case .selection: return "OptionList"
        case .text: return "TextBubble & RichText"
        case .media: return "MediaCard"
        case .table: return "DataTable"
        case .metric: return "MetricSummary"
        case .summary: return "SummaryCard & ItemHeader"
        case .documents: return "AcknowledgementRow"
        case .actions: return "Actions & Suggestions"
        case .welcome: return "WelcomeContent & QuickActionList"
        case .chrome: return "NavigationHeader & DateSeparator"
        case .feedback: return "ActivityStatus & LoadingStateView"
        case .artwork: return "Dummy artwork & sizes"
        }
    }
}
