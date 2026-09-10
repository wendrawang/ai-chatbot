import Combine
import SwiftUI
import TanyaAIDesignSystem
import TanyaAIDomain
import UIKit

struct TanyaAIMessageTableView: UIViewRepresentable {
    let state: TanyaAIMessageListState
    let theme: TanyaAITheme
    let handlers: TanyaAIMessageRowHandlers

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = TanyaAITrackingTableView(frame: .zero, style: .plain)
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.separatorStyle = .none
        tableView.backgroundColor = theme.colors.background
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.keyboardDismissMode = .interactive
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        tableView.accessibilityIdentifier = "chat.messageTable"
        tableView.register(
            TanyaAIHostingTableViewCell.self,
            forCellReuseIdentifier: TanyaAIHostingTableViewCell.reuseIdentifier
        )
        context.coordinator.attach(tableView)
        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        context.coordinator.update(state, theme: theme, handlers: handlers)
    }
}
