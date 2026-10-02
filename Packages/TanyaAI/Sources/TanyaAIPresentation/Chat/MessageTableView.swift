import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

struct MessageTableView: UIViewRepresentable {
    let state: TanyaAIMessageListState
    let theme: Theme
    let handlers: TanyaAIMessageRowHandlers
    @Environment(\.copyCatalog) private var copy
    @Environment(\.artwork) private var artwork
    @Environment(\.imageLoader) private var imageLoader

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = LayoutTrackingTableView(frame: .zero, style: .plain)
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.separatorStyle = .none
        tableView.backgroundColor = theme.colors.background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = artwork.size(DesignKitMetrics.Size.estimatedRowHeight)
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset = UIEdgeInsets(
            top: artwork.size(DesignKitMetrics.Spacing.snug), left: 0,
            bottom: artwork.size(DesignKitMetrics.Spacing.snug), right: 0
        )
        tableView.accessibilityIdentifier = "chat.messageTable"
        tableView.register(
            MessageHostingCell.self,
            forCellReuseIdentifier: MessageHostingCell.reuseIdentifier
        )
        context.coordinator.attach(tableView)
        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        context.coordinator.update(
            state, theme: theme, handlers: handlers, artwork: artwork, imageLoader: imageLoader, copy: copy
        )
    }
}
