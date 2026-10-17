//
//  TanyaAIHost.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI
import UIKit

/// Own once in the host's app/session state. Attach with `.tanyaAIHost(host)` and call `present()`.
@MainActor
public final class TanyaAIHost: ObservableObject {
    private let isEnabled: Bool
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool
    private let pushTransition = TanyaAIPushTransition()
    private var locale = Locale.current
    private weak var anchor: UIViewController?
    private weak var presented: UIViewController?

    public var isPresenting: Bool { presented != nil }

    /// Return true when the host accepts the draft; false keeps it in the composer.
    public init(
        isEnabled: Bool = true, onNewConversation: (() -> Void)? = nil,
        onSend: @escaping (String) -> Bool
    ) {
        self.isEnabled = isEnabled
        self.onNewConversation = onNewConversation
        self.onSend = onSend
    }

    /// Presents independently of the host navigation stack. Repeated/offscreen requests are ignored.
    public func present() {
        present { EmptyView() }
    }

    /// Uses the host's current language for this presentation, without observing language changes.
    public func present(languageCode: String) {
        present(languageCode: languageCode) { EmptyView() }
    }

    /// Supplies a scrollable UI fixture or feature content, without changing host navigation.
    /// An explicit language takes precedence over the anchor's environment locale for this presentation only.
    public func present<Content: View>(languageCode: String? = nil, @ViewBuilder content: () -> Content) {
        guard presented == nil, let anchor, anchor.viewIfLoaded?.window != nil else { return }
        var presenter = anchor
        while let parent = presenter.parent { presenter = parent }
        guard presenter.presentedViewController == nil, !presenter.isBeingDismissed else { return }
        let presentationLocale = languageCode.map { Locale(identifier: $0) } ?? locale
        let screen = ChatScreen(
            isEnabled: isEnabled, onBack: { [weak self] in self?.dismiss() },
            onNewConversation: onNewConversation, onSend: onSend, content: content
        )
        .environment(\.locale, presentationLocale)
        .preferredColorScheme(.light)
        let controller = UIHostingController(rootView: screen)
        controller.modalPresentationStyle = .fullScreen
        controller.transitioningDelegate = pushTransition
        presented = controller
        presenter.present(controller, animated: true)
    }

    /// Completion runs after the feature is gone, so the host can safely continue its own routing.
    public func dismiss(completion: (() -> Void)? = nil) {
        guard let controller = presented else {
            completion?()
            return
        }
        guard !controller.isBeingDismissed else { return }
        controller.dismiss(animated: true) { [weak self, weak controller] in
            if self?.presented === controller { self?.presented = nil }
            completion?()
        }
    }

    func attach(anchor: UIViewController, locale: Locale) {
        self.anchor = anchor
        self.locale = locale
    }

    func detach(anchor: UIViewController) {
        if self.anchor === anchor { self.anchor = nil }
    }
}
