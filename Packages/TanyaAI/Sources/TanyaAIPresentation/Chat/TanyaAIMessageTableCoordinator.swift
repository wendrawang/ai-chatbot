import Combine
import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

extension MessageTableView {
    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        /// A layout that will not settle must not spin the loop in
        /// `parkAtBottom`. Two passes cover the usual case: aim at the
        /// estimated bottom, then at the measured one.
        static let maximumParkingPasses = 4

        weak var tableView: UITableView?
        var state = TanyaAIMessageListState.empty
        var isFollowingLatestMessage = true
        var scrollRequestIdentifier = 0
        private var copy = CopyCatalog()
        private var theme = Theme.sandbox
        private var screenMetrics = ArtworkMetrics.screen
        private var imageLoader: ImageLoading = ImageLoader.shared
        private var handlers = TanyaAIMessageRowHandlers.inert
        private var subscriptions: [ObjectIdentifier: AnyCancellable] = [:]
        private var isHeightUpdatePending = false
        weak var scrollControl: TanyaAIMessageScrollControl?
        var latestRequestIdentifier = 0

        func attach(_ tableView: LayoutTrackingTableView) {
            self.tableView = tableView
            tableView.onLayoutChange = { [weak self] in
                self?.tableLayoutDidChange()
            }
        }

        func update(
            _ state: TanyaAIMessageListState,
            theme: Theme,
            handlers: TanyaAIMessageRowHandlers,
            imageLoader: ImageLoading = ImageLoader.shared,
            copy: CopyCatalog = CopyCatalog()
        ) {
            let previous = self.state
            let currentMetrics = ArtworkMetrics.screen
            let isThemeChanged = self.theme != theme || screenMetrics != currentMetrics
                || self.imageLoader !== imageLoader || self.copy != copy
            self.copy = copy
            self.state = state
            self.theme = theme
            screenMetrics = currentMetrics
            self.imageLoader = imageLoader
            self.handlers = handlers
            bindMessages(state.messages)

            tableView?.backgroundColor = theme.colors.background
            tableView?.estimatedRowHeight = DesignKitMetrics.Size.estimatedRowHeight.sizeInArtwork
            let inset = DesignKitMetrics.Spacing.snug.sizeInArtwork
            tableView?.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
            let isRowStructureChanged = state.rowsDiffer(from: previous)
            if isRowStructureChanged || isThemeChanged {
                tableView?.reloadData()
            }
            reportScrollPosition()
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
                withIdentifier: MessageHostingCell.reuseIdentifier,
                for: indexPath
            ) as? MessageHostingCell else {
                return UITableViewCell()
            }
            guard let kind = state.kind(at: indexPath.row) else {
                return cell
            }
            cell.configure(rootView: rowView(for: kind))
            return cell
        }

        private func rowView(
            for kind: TanyaAIMessageRowKind
        ) -> MessageTableRow {
            MessageTableRow(
                kind: kind,
                theme: theme,
                handlers: handlers,
                copy: copy,
                imageLoader: imageLoader
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
            guard let tableView else { return }
            for case let cell as MessageHostingCell in tableView.visibleCells {
                cell.invalidateHostedSize()
            }
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
                tableView.layoutIfNeeded()
            }
            reportScrollPosition()
            guard isFollowingLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        private func tableLayoutDidChange() {
            refreshScreenMetrics()
            reportScrollPosition()
            guard isFollowingLatestMessage else {
                return
            }
            scheduleScrollToBottom(animated: false)
        }

        private func refreshScreenMetrics() {
            let current = ArtworkMetrics.screen
            guard screenMetrics != current, let tableView else { return }
            screenMetrics = current
            theme = theme.resolved(traits: tableView.traitCollection)
            tableView.estimatedRowHeight = DesignKitMetrics.Size.estimatedRowHeight.sizeInArtwork
            let inset = DesignKitMetrics.Spacing.snug.sizeInArtwork
            tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
            tableView.reloadData()
        }
    }
}
