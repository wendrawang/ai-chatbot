import Combine
import SwiftUI
import TanyaAIDesignSystem
import TanyaAIDomain
import UIKit

struct TanyaAIMessageTableView: UIViewRepresentable {
    let messages: [TanyaAIMessageItemViewModel]
    let isGenerating: Bool
    let theme: TanyaAITheme
    let onApproval: (TanyaAIApprovalPayload) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
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
        context.coordinator.update(
            messages: messages,
            isGenerating: isGenerating,
            theme: theme,
            onApproval: onApproval
        )
    }
}

extension TanyaAIMessageTableView {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        private weak var tableView: UITableView?
        private var messages: [TanyaAIMessageItemViewModel] = []
        private var isGenerating = false
        private var theme = TanyaAITheme.sandbox
        private var onApproval: (TanyaAIApprovalPayload) -> Void = { _ in }
        private var subscriptions: [String: AnyCancellable] = [:]

        func attach(_ tableView: UITableView) {
            self.tableView = tableView
        }

        func update(
            messages: [TanyaAIMessageItemViewModel],
            isGenerating: Bool,
            theme: TanyaAITheme,
            onApproval: @escaping (TanyaAIApprovalPayload) -> Void
        ) {
            let previousRows = rowCount
            let previousIdentifiers = self.messages.map(\.id)
            let identifiers = messages.map(\.id)
            self.messages = messages
            self.isGenerating = isGenerating
            self.theme = theme
            self.onApproval = onApproval
            bindMessages(messages)

            guard previousIdentifiers != identifiers
                    || previousRows != rowCount else {
                tableView?.backgroundColor = theme.colors.background
                return
            }
            tableView?.reloadData()
            scrollToBottom(animated: previousRows > 0)
        }

        func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection section: Int
        ) -> Int {
            rowCount
        }

        func tableView(
            _ tableView: UITableView,
            cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TanyaAIHostingTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? TanyaAIHostingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(rootView: rowView(at: indexPath.row))
            return cell
        }

        private var rowCount: Int {
            messages.count + (isGenerating ? 1 : 0)
        }

        private func rowView(at index: Int) -> TanyaAIMessageTableRow {
            let message = index < messages.count ? messages[index] : nil
            return TanyaAIMessageTableRow(
                message: message,
                theme: theme,
                onApproval: onApproval
            )
        }

        private func bindMessages(_ messages: [TanyaAIMessageItemViewModel]) {
            let identifiers = Set(messages.map(\.id))
            subscriptions = subscriptions.filter { identifiers.contains($0.key) }
            messages.forEach { message in
                guard subscriptions[message.id] == nil else {
                    return
                }
                subscriptions[message.id] = message.objectWillChange.sink {
                    [weak self] in

                    DispatchQueue.main.async {
                        self?.refreshRowHeight()
                    }
                }
            }
        }

        private func refreshRowHeight() {
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }

        private func scrollToBottom(animated: Bool) {
            guard rowCount > 0 else {
                return
            }
            tableView?.scrollToRow(
                at: IndexPath(row: rowCount - 1, section: 0),
                at: .bottom,
                animated: animated
            )
        }
    }
}

struct TanyaAIMessageTableRow: View {
    let message: TanyaAIMessageItemViewModel?
    let theme: TanyaAITheme
    let onApproval: (TanyaAIApprovalPayload) -> Void

    var body: some View {
        Group {
            if let message = message {
                TanyaAIMessageRowView(
                    viewModel: message,
                    onApproval: onApproval
                )
            } else {
                TanyaAITypingIndicatorView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .tanyaAITheme(theme)
    }
}
