//
//  ChatViewController+Timeline.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import UIKit

extension ChatViewController
{
    func render(_ state: ChatState)
    {
        guard !isApplying
        else
        {
            queuedState = state
            return
        }

        isApplying = true
        let isNearBottom = table.contentSize.height - table.contentOffset.y - table.bounds.height
            <= CustomSizes.nearBottomThreshold
        let offset = table.contentOffset
        let anchorChanged = state.promptAnchor != previousAnchor
        let isLatest = state.latestRequest != previousLatest
        updateChrome(state)
        rows?.update(state)
        {
            [weak self] in
            guard let self
            else
            {
                return
            }

            self.updateRowHeights()
            self.positionTimeline(
                state,
                offset: offset,
                isAnchorChanged: anchorChanged,
                isLatest: isLatest,
                isNearBottom: isNearBottom)
            self.updateLatestButton()
            self.previousAnchor = state.promptAnchor
            self.previousLatest = state.latestRequest
            self.isApplying = false
            guard let pending = self.queuedState
            else
            {
                return
            }

            self.queuedState = nil
            self.render(pending)
        }
    }

    private func updateRowHeights()
    {
        for cell in table.visibleCells
        {
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
        }

        UIView.performWithoutAnimation
        {
            table.beginUpdates()
            table.endUpdates()
        }

        table.layoutIfNeeded()
    }

    private func positionTimeline(
        _ state: ChatState,
        offset: CGPoint,
        isAnchorChanged: Bool,
        isLatest: Bool,
        isNearBottom: Bool)
    {
        guard !isAnchorChanged, !isLatest
        else
        {
            positionRequested(state, isLatest: isLatest)
            return
        }

        guard isFollowingLatest, isNearBottom
        else
        {
            table.setContentOffset(offset, animated: false)
            return
        }

        scrollToBottom()
    }

    private func positionRequested(_ state: ChatState, isLatest: Bool)
    {
        guard !isLatest, let id = state.promptAnchor,
              let path = rows?.dataSource?.indexPath(for: id)
        else
        {
            isFollowingLatest = true
            table.contentInset.bottom = 0
            scrollToBottom()
            return
        }

        let rect = table.rectForRow(at: path)
        let target = max(-table.adjustedContentInset.top, rect.minY - CustomSizes.promptPreview)
        table.contentInset.bottom = max(0, target + table.bounds.height - table.contentSize.height)
        table.setContentOffset(CGPoint(x: 0, y: target), animated: false)
        isFollowingLatest = false
    }

    private func scrollToBottom()
    {
        let bottom = max(
            -table.adjustedContentInset.top,
            table.contentSize.height - table.bounds.height + table.adjustedContentInset.bottom)
        table.setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
    }
}

extension ChatViewController: UITableViewDelegate
{
    func scrollViewWillBeginDragging(_: UIScrollView)
    {
        isFollowingLatest = false
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate isDecelerating: Bool)
    {
        guard !isDecelerating
        else
        {
            return
        }

        resumeFollowingIfNearBottom()
    }

    func scrollViewDidEndDecelerating(_: UIScrollView)
    {
        resumeFollowingIfNearBottom()
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath)
    {
        (cell as? HostingTableViewCell<TransferFlowView>)?.attachHostedController(to: self)
        (cell as? HostingTableViewCell<TransferSuggestion>)?.attachHostedController(to: self)
    }

    func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath)
    {
        (cell as? HostingTableViewCell<TransferFlowView>)?.detachHostedController()
        (cell as? HostingTableViewCell<TransferSuggestion>)?.detachHostedController()
    }
}
