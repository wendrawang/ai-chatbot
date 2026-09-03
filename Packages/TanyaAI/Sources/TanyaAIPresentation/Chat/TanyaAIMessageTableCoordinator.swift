import Combine
import SwiftUI
import TanyaAIDesignSystem
import TanyaAIDomain
import UIKit

extension TanyaAIMessageTableView {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        private weak var tableView: UITableView?
        private var messages: [TanyaAIMessageItemViewModel] = []
        private var isGenerating = false
        private var showsSuggestions = false
        private var followsLatestMessage = true
        private var scrollRequestIdentifier = 0
        private var theme = TanyaAITheme.sandbox
        private var onApprovalEdit: (TanyaAIApprovalPayload) -> Void = { _ in }
        private var onApprovalCancel: (TanyaAIApprovalPayload) -> Void = { _ in }
        private var onApproval: (TanyaAIApprovalPayload) -> Void = { _ in }
        private var onAction: (TanyaAIAction) -> Void = { _ in }
        private var subscriptions: [String: AnyCancellable] = [:]

        func attach(_ tableView: TanyaAITrackingTableView) {
            self.tableView = tableView
            tableView.onLayoutChange = { [weak self] in
                self?.tableLayoutDidChange()
            }
        }

        func update(
            messages: [TanyaAIMessageItemViewModel],
            isGenerating: Bool,
            showsSuggestions: Bool,
            theme: TanyaAITheme,
            onApprovalEdit: @escaping (TanyaAIApprovalPayload) -> Void,
            onApprovalCancel: @escaping (TanyaAIApprovalPayload) -> Void,
            onApproval: @escaping (TanyaAIApprovalPayload) -> Void,
            onAction: @escaping (TanyaAIAction) -> Void
        ) {
            let updateState = makeUpdateState(
                messages: messages,
                isGenerating: isGenerating,
                showsSuggestions: showsSuggestions
            )
            self.messages = messages
            self.isGenerating = isGenerating
            self.showsSuggestions = showsSuggestions
            self.theme = theme
            self.onApprovalEdit = onApprovalEdit
            self.onApprovalCancel = onApprovalCancel
            self.onApproval = onApproval
            self.onAction = onAction
            bindMessages(messages)

            tableView?.backgroundColor = theme.colors.background
            if updateState.rowsChanged {
                tableView?.reloadData()
            }
            if updateState.requiresBottomAlignment && followsLatestMessage {
                scheduleScrollToBottom(animated: false)
            }
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

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            followsLatestMessage = false
        }

        func scrollViewDidEndDragging(
            _ scrollView: UIScrollView,
            willDecelerate decelerate: Bool
        ) {
            guard !decelerate else {
                return
            }
            followsLatestMessage = isNearBottom(scrollView)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            followsLatestMessage = isNearBottom(scrollView)
        }

        private var rowCount: Int {
            messages.count + (isGenerating ? 1 : 0)
        }

        private func rowView(at index: Int) -> TanyaAIMessageTableRow {
            let message = index < messages.count ? messages[index] : nil
            return TanyaAIMessageTableRow(
                message: message,
                theme: theme,
                onApprovalEdit: onApprovalEdit,
                onApprovalCancel: onApprovalCancel,
                onApproval: onApproval,
                onAction: onAction
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
            guard followsLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        private func tableLayoutDidChange() {
            guard followsLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        private func scheduleScrollToBottom(animated: Bool) {
            scrollRequestIdentifier += 1
            let requestIdentifier = scrollRequestIdentifier
            DispatchQueue.main.async { [weak self] in
                guard self?.scrollRequestIdentifier == requestIdentifier else {
                    return
                }
                self?.scrollToBottom(animated: animated)
            }
        }

        private func scrollToBottom(animated: Bool) {
            guard rowCount > 0, let tableView = tableView else {
                return
            }
            tableView.layoutIfNeeded()
            let minimumOffset = -tableView.adjustedContentInset.top
            let maximumOffset = max(
                minimumOffset,
                tableView.contentSize.height
                    - tableView.bounds.height
                    + tableView.adjustedContentInset.bottom
            )
            guard abs(tableView.contentOffset.y - maximumOffset) > 0.5 else {
                return
            }
            tableView.setContentOffset(
                CGPoint(x: 0, y: maximumOffset),
                animated: animated
            )
        }

        private func isNearBottom(_ scrollView: UIScrollView) -> Bool {
            let visibleBottom = scrollView.contentOffset.y
                + scrollView.bounds.height
                - scrollView.adjustedContentInset.bottom
            return scrollView.contentSize.height - visibleBottom < 80
        }

        private func makeUpdateState(
            messages: [TanyaAIMessageItemViewModel],
            isGenerating: Bool,
            showsSuggestions: Bool
        ) -> UpdateState {
            let identifiersChanged = self.messages.map(\.id) != messages.map(\.id)
            let nextRows = messages.count + (isGenerating ? 1 : 0)
            let rowsChanged = identifiersChanged || rowCount != nextRows
            return UpdateState(
                rowsChanged: rowsChanged,
                requiresBottomAlignment: rowsChanged
                    || self.showsSuggestions != showsSuggestions
            )
        }
    }
}

private struct UpdateState {
    let rowsChanged: Bool
    let requiresBottomAlignment: Bool
}
