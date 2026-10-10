import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

struct MessageTableView: UIViewControllerRepresentable {
    @Environment(\.copyCatalog)
    private var copy
    @Environment(\.imageLoader)
    private var imageLoader
    let state: TanyaAIMessageListState
    let theme: Theme
    @ObservedObject
    var scrollControl: TanyaAIMessageScrollControl
    let handlers: TanyaAIMessageRowHandlers

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UITableViewController {
        let controller = UITableViewController(style: .plain)
        let tableView = LayoutTrackingTableView(frame: .zero, style: .plain)
        controller.tableView = tableView
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
        context.coordinator.attach(tableView, parent: controller)
        return controller
    }

    func updateUIViewController(_ controller: UITableViewController, context: Context) {
        context.coordinator.updateScrollControl(scrollControl)
        context.coordinator.update(
            state, theme: theme, handlers: handlers, imageLoader: imageLoader, copy: copy
        )
    }
    static func dismantleUIViewController(_ controller: UITableViewController, coordinator: Coordinator) {
        coordinator.detach()
    }

}
