import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

extension TanyaAIMessageTableView {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        /// A layout that will not settle must not spin the loop in
        /// `parkAtBottom`. Two passes cover the usual case: aim at the
        /// estimated bottom, then at the measured one.
        private static let maximumParkingPasses = 4

        private weak var tableView: UITableView?
        private var state = TanyaAIMessageListState.empty
        private var isFollowingLatestMessage = true
        private var scrollRequestIdentifier = 0
        private var theme = Theme.sandbox
        private var handlers = TanyaAIMessageRowHandlers.inert
        private var subscriptions: [ObjectIdentifier: AnyCancellable] = [:]
        private var isHeightUpdatePending = false

        func attach(_ tableView: TanyaAITrackingTableView) {
            self.tableView = tableView
            tableView.onLayoutChange = { [weak self] in
                self?.tableLayoutDidChange()
            }
        }

        func update(
            _ state: TanyaAIMessageListState,
            theme: Theme,
            handlers: TanyaAIMessageRowHandlers
        ) {
            let previous = self.state
            let isThemeChanged = self.theme != theme
            self.state = state
            self.theme = theme
            self.handlers = handlers
            bindMessages(state.messages)

            tableView?.backgroundColor = theme.colors.background
            let isRowStructureChanged = state.rowsDiffer(from: previous)
            if isRowStructureChanged || isThemeChanged {
                tableView?.reloadData()
            }
            guard isFollowingLatestMessage else {
                return
            }
            if previous.isRestoring, state.isRestoring == false {
                parkAtBottom()
            } else if isRowStructureChanged {
                scheduleScrollToBottom(animated: false)
            }
        }

        func tableView(
            _ tableView: UITableView,
            numberOfRowsInSection section: Int
        ) -> Int {
            state.rowCount
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
            guard let kind = state.kind(at: indexPath.row) else {
                return cell
            }
            cell.configure(rootView: rowView(for: kind))
            return cell
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isFollowingLatestMessage = false
        }

        func scrollViewDidEndDragging(
            _ scrollView: UIScrollView,
            willDecelerate isDecelerating: Bool
        ) {
            guard !isDecelerating else {
                return
            }
            isFollowingLatestMessage = isNearBottom(scrollView)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isFollowingLatestMessage = isNearBottom(scrollView)
        }

        private func rowView(
            for kind: TanyaAIMessageRowKind
        ) -> TanyaAIMessageTableRow {
            TanyaAIMessageTableRow(
                kind: kind,
                theme: theme,
                handlers: handlers
            )
        }

        private func bindMessages(_ messages: [TanyaAIMessageItemViewModel]) {
            let identifiers = Set(messages.map(ObjectIdentifier.init))
            subscriptions = subscriptions.filter { identifiers.contains($0.key) }
            messages.forEach { message in
                guard subscriptions[ObjectIdentifier(message)] == nil else {
                    return
                }
                subscriptions[ObjectIdentifier(message)] = message.objectWillChange.sink { [weak self] in
                    self?.scheduleHeightUpdate()
                }
            }
        }

        private func scheduleHeightUpdate() {
            guard !isHeightUpdatePending else { return }
            isHeightUpdatePending = true
            DispatchQueue.main.async { [weak self] in
                self?.isHeightUpdatePending = false
                self?.refreshRowHeight()
            }
        }

        private func refreshRowHeight() {
            tableView?.beginUpdates()
            tableView?.endUpdates()
            guard isFollowingLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        private func tableLayoutDidChange() {
            guard isFollowingLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        /// Scrolls to the end now, and keeps doing it until the height stops
        /// moving.
        ///
        /// A restored conversation has to reach the screen already at its
        /// latest message. Scrolling on the next runloop, the way an appended
        /// message can afford to, would draw one frame at the top of the
        /// conversation first - which is the jump this removes. Self-sizing
        /// cells report their real height only once laid out, so the first
        /// scroll aims at an estimated bottom and the content grows out from
        /// under it; converging inside this one runloop means the frame that
        /// reaches the screen is the settled one.
        private func parkAtBottom() {
            guard let tableView = tableView else {
                return
            }
            var lastHeight: CGFloat = -1
            var passes = 0
            while passes < Self.maximumParkingPasses,
                  tableView.contentSize.height != lastHeight {
                lastHeight = tableView.contentSize.height
                tableView.layoutIfNeeded()
                scrollToBottom(animated: false)
                passes += 1
            }
        }

        private func scheduleScrollToBottom(animated isAnimated: Bool) {
            scrollRequestIdentifier += 1
            let requestIdentifier = scrollRequestIdentifier
            DispatchQueue.main.async { [weak self] in
                guard self?.scrollRequestIdentifier == requestIdentifier else {
                    return
                }
                self?.scrollToBottom(animated: isAnimated)
            }
        }

        private func scrollToBottom(animated isAnimated: Bool) {
            guard state.rowCount > 0, let tableView = tableView else {
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
                animated: isAnimated
            )
        }

        private func isNearBottom(_ scrollView: UIScrollView) -> Bool {
            let visibleBottom = scrollView.contentOffset.y
                + scrollView.bounds.height
                - scrollView.adjustedContentInset.bottom
            return scrollView.contentSize.height - visibleBottom < 80
        }
    }
}
