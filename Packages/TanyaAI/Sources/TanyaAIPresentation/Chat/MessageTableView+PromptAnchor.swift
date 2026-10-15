import DesignKit
import UIKit

extension MessageTableView.Coordinator {
    /// A short answer needs trailing room to place its question near the top.
    /// This inset is layout space only; it never changes the order of messages.
    func parkAtPrompt() {
        guard !isAdjustingScroll, let tableView, let identifier = activePromptIdentifier,
            let row = state.rowIndex(messageIdentifier: identifier), tableView.bounds.height > 0
        else { return }
        isAdjustingScroll = true
        defer {
            isAdjustingScroll = false
            reportScrollPosition()
        }
        var lastHeight: CGFloat = -1
        for _ in 0..<Self.maximumParkingPasses {
            tableView.layoutIfNeeded()
            let prompt = tableView.rectForRow(at: IndexPath(row: row, section: 0))
            let desired = max(
                -tableView.adjustedContentInset.top,
                prompt.minY - tableView.adjustedContentInset.top
                    - ChatLayoutMetrics.previousAnswerPreview.scaledToArtwork
            )
            let actualBottom =
                tableView.contentSize.height - tableView.bounds.height
                + tableView.adjustedContentInset.bottom - promptTrailingInset
            promptTrailingInset = max(0, desired - actualBottom)
            updateContentInset()
            if abs(tableView.contentOffset.y - desired) > DesignKitMetrics.Layout.measurementTolerance {
                tableView.setContentOffset(CGPoint(x: 0, y: desired), animated: false)
            }
            if tableView.contentSize.height == lastHeight { break }
            lastHeight = tableView.contentSize.height
        }
    }

    func updateContentInset() {
        guard let tableView else { return }
        let margin = DesignKitMetrics.Spacing.snug.scaledToArtwork
        let inset = UIEdgeInsets(top: margin, left: 0, bottom: margin + promptTrailingInset, right: 0)
        if tableView.contentInset != inset { tableView.contentInset = inset }
    }

    /// Coalesce table and hosted-row layout notifications into one main-loop pass.
    /// Both the table callback and queued work capture the coordinator weakly.
    func schedulePositionUpdate() {
        guard !isAdjustingScroll, !isPositionUpdatePending,
            activePromptIdentifier != nil || isFollowingLatestMessage
        else { return }
        isPositionUpdatePending = true
        let identifier = scrollRequestIdentifier
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isPositionUpdatePending = false
            guard self.scrollRequestIdentifier == identifier else { return }
            if self.activePromptIdentifier != nil {
                self.parkAtPrompt()
            } else if self.isFollowingLatestMessage {
                self.parkAtBottom()
            }
        }
    }
}
