import UIKit

public final class LayoutTrackingTableView: UITableView {
    public var onLayoutChange: (() -> Void)?

    private var trackedBoundsSize = CGSize.zero
    private var trackedContentSize = CGSize.zero

    public override func layoutSubviews() {
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
