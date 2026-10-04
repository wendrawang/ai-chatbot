import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

struct MessageTableView: UIViewRepresentable {
    let state: TanyaAIMessageListState
    let theme: Theme
    @ObservedObject var scrollControl: TanyaAIMessageScrollControl
    let handlers: TanyaAIMessageRowHandlers
    @Environment(\.copyCatalog) private var copy

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
        tableView.estimatedRowHeight = DesignKitMetrics.Size.estimatedRowHeight.sizeInArtwork
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset = UIEdgeInsets(
            top: DesignKitMetrics.Spacing.snug.sizeInArtwork, left: 0,
            bottom: DesignKitMetrics.Spacing.snug.sizeInArtwork, right: 0
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
        context.coordinator.updateScrollControl(scrollControl)
        context.coordinator.update(
            state, theme: theme, handlers: handlers, imageLoader: imageLoader, copy: copy
        )
    }
}
