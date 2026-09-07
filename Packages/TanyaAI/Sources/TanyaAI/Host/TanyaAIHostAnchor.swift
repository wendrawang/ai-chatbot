import SwiftUI
import UIKit

/// Gives a SwiftUI screen a controller to present the feature from.
///
/// The feature is a `UIViewController`, and a SwiftUI screen has none of its
/// own. Reaching into the scene delegate only works when the screen *is* the
/// window root, which a coordinator shown after login never is.
///
/// The anchor is an empty, zero-sized controller placed in the hierarchy for
/// no reason other than to be that handle. UIKit walks up from it to the
/// nearest controller that can present, so the feature opens over the screen
/// the customer is looking at - without ever entering the host's
/// `NavigationView`.
struct TanyaAIHostAnchor: UIViewControllerRepresentable {
    let host: TanyaAIHost

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
        // Re-attaching on every update is deliberate: the host holds the
        // controller weakly, so a rebuilt screen reconnects itself.
        host.attach(anchor: controller)
    }
}

public extension View {
    /// Marks this screen as the place Tanya AI is presented from.
    ///
    /// Apply it once, on the screen that owns the host. The feature is
    /// presented as its own controller, so the host's own navigation stack is
    /// never involved and cannot be disturbed by it.
    func tanyaAIHost(_ host: TanyaAIHost) -> some View {
        background(
            TanyaAIHostAnchor(host: host)
                .frame(width: 0, height: 0)
        )
    }
}
