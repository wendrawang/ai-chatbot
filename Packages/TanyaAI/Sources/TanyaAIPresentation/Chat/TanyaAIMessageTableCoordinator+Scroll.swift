import DesignKit
import UIKit

extension MessageTableView.Coordinator {
    func updateScrollControl(_ control: TanyaAIMessageScrollControl?) {
        scrollControl = control
        guard let control, control.requestIdentifier != latestRequestIdentifier else { return }
        latestRequestIdentifier = control.requestIdentifier
        isFollowingLatestMessage = true
        parkAtBottom()
        scheduleScrollToBottom(animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        reportScrollPosition()
    }

    func reportScrollPosition() {
        guard let tableView else { return }
        scrollControl?.updateVisibility(!isFollowingLatestMessage && !isNearBottom(tableView))
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isFollowingLatestMessage = false
        scrollRequestIdentifier += 1
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
    func parkAtBottom() {
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

    func scheduleScrollToBottom(animated isAnimated: Bool) {
        scrollRequestIdentifier += 1
        let requestIdentifier = scrollRequestIdentifier
        DispatchQueue.main.async { [weak self] in
            guard self?.scrollRequestIdentifier == requestIdentifier,
                  self?.isFollowingLatestMessage == true else {
                return
            }
            self?.scrollToBottom(animated: isAnimated)
        }
    }

    func scrollToBottom(animated isAnimated: Bool) {
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
        guard abs(tableView.contentOffset.y - maximumOffset) > DesignKitMetrics.Layout.measurementTolerance else {
            return
        }
        tableView.setContentOffset(
            CGPoint(x: 0, y: maximumOffset),
            animated: isAnimated
        )
        reportScrollPosition()
    }

    func isNearBottom(_ scrollView: UIScrollView) -> Bool {
        let visibleBottom = scrollView.contentOffset.y
            + scrollView.bounds.height
            - scrollView.adjustedContentInset.bottom
        let threshold = artwork.size(DesignKitMetrics.Layout.scrollFollowThreshold)
        return scrollView.contentSize.height - visibleBottom < threshold
    }
}
