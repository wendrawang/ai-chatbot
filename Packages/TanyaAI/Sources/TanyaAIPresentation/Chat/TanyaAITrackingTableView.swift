import UIKit

final class TanyaAITrackingTableView: UITableView {
    var onLayoutChange: (() -> Void)?

    private var trackedBoundsSize = CGSize.zero
    private var trackedContentSize = CGSize.zero

    override func layoutSubviews() {
        super.layoutSubviews()

        let boundsChanged = trackedBoundsSize != bounds.size
        let contentChanged = trackedContentSize != contentSize
        guard boundsChanged || contentChanged else {
            return
        }
        trackedBoundsSize = bounds.size
        trackedContentSize = contentSize
        onLayoutChange?()
    }
}
