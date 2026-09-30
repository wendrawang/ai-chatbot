import UIKit

final class TanyaAITrackingTableView: UITableView {
    var onLayoutChange: (() -> Void)?

    private var trackedBoundsSize = CGSize.zero
    private var trackedContentSize = CGSize.zero

    override func layoutSubviews() {
        super.layoutSubviews()

        let isBoundsChanged = trackedBoundsSize != bounds.size
        let isContentChanged = trackedContentSize != contentSize
        guard isBoundsChanged || isContentChanged else {
            return
        }
        trackedBoundsSize = bounds.size
        trackedContentSize = contentSize
        onLayoutChange?()
    }
}
