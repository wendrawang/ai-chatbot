import Combine
import Foundation

/// Only changes when the scroll threshold is crossed or the button is tapped.
final class TanyaAIMessageScrollControl: ObservableObject {
    @Published private(set) var isAwayFromLatest = false
    @Published private(set) var requestIdentifier = 0
    private var isPendingVisibility: Bool?

    func returnToLatest() {
        isPendingVisibility = nil
        isAwayFromLatest = false
        requestIdentifier += 1
    }

    /// UIKit can report layout during a SwiftUI update; publish on the next runloop.
    func updateVisibility(_ isVisible: Bool) {
        guard isPendingVisibility != isVisible,
              isPendingVisibility != nil || isAwayFromLatest != isVisible else { return }
        isPendingVisibility = isVisible
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isPendingVisibility == isVisible else { return }
            self.isPendingVisibility = nil
            if self.isAwayFromLatest != isVisible { self.isAwayFromLatest = isVisible }
        }
    }
}
