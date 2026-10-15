import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

struct MessageTableView: UIViewControllerRepresentable {
    @Environment(\.copyCatalog)
    private var copy
    let state: TanyaAIMessageListState
    let theme: Theme
    @ObservedObject
    var scrollControl: TanyaAIMessageScrollControl
    let handlers: TanyaAIMessageRowHandlers

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        // SwiftUI owns keyboard/safe-area layout; UITableViewController would
        // also adjust the table's insets for the same keyboard.
        let controller = UIViewController()
        let tableView = LayoutTrackingTableView(frame: .zero, style: .plain)
        controller.view = tableView
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = DesignKitMetrics.Size.estimatedRowHeight.sizeInArtwork
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .never
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

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        context.coordinator.updateScrollControl(scrollControl)
        context.coordinator.update(
            state, theme: theme, handlers: handlers, copy: copy
        )
    }
    static func dismantleUIViewController(_ controller: UIViewController, coordinator: Coordinator) {
        coordinator.detach()
    }

}
