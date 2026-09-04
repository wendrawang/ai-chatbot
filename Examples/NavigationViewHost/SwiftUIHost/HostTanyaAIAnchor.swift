import SwiftUI
import UIKit

/// Gives a SwiftUI screen something to present the feature from.
///
/// `TanyaAIModule` hands back a `UIViewController`, and the presenter needs a
/// controller to present it on. Reaching into the scene delegate works only
/// when the screen *is* the window root. A coordinator that appears after
/// login, inside a tab, or partway down a stack has no such handle - and that
/// is what most host applications actually look like.
///
/// The anchor is an empty, zero-sized controller placed in the hierarchy for
/// no reason other than to be that handle. Presenting on it behaves like
/// presenting on the screen the customer is looking at, because UIKit walks up
/// to the nearest controller that can present.
struct TanyaAIHostAnchor: UIViewControllerRepresentable {
    let presenter: HostTanyaAIPresenter

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        // It must never intercept a touch meant for the screen behind it.
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(
        _ controller: UIViewController,
        context: Context
    ) {
        // Re-attaching on every update is deliberate: the presenter holds the
        // controller weakly, so a screen that is rebuilt reconnects itself.
        presenter.attach(rootController: controller)
    }
}

extension View {
    /// Marks this screen as the place Tanya AI is presented from.
    ///
    /// Apply it once, on the screen that owns the presenter. Applying it to
    /// several screens at once is not harmful - the last one to update wins -
    /// but it makes the presentation point harder to reason about.
    func tanyaAIHost(_ presenter: HostTanyaAIPresenter) -> some View {
        background(
            TanyaAIHostAnchor(presenter: presenter)
                .frame(width: 0, height: 0)
        )
    }
}
