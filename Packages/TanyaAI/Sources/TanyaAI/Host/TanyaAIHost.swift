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
    private let hostEnvironment: TanyaAIHostEnvironment
    private var dismissCompletions: [() -> Void] = []
    private weak var anchor: UIViewController?
    private weak var presented: UIViewController?

    public var isPresenting: Bool { presented != nil }

    /// Bahasa fitur. Isi dari setting bahasa host (mis. Localize_Swift) setiap kali berubah;
    /// fitur yang sedang terbuka langsung mengikuti tanpa kehilangan draft.
    public var locale: Locale {
        get { hostEnvironment.locale }
        set { hostEnvironment.locale = newValue }
    }

    /// Palette fitur. Isi dari hasil inquiry proposition; sebelum itu memakai palette default.
    public var colors: any FigmaColorProtocol {
        get { hostEnvironment.colors }
        set { hostEnvironment.colors = newValue }
    }

    /// Return true when the host accepts the draft; false keeps it in the composer.
    public init(
        locale: Locale = .current, colors: any FigmaColorProtocol = EnvironmentValues().designColors,
        isEnabled: Bool = true, onNewConversation: (() -> Void)? = nil,
        onSend: @escaping (String) -> Bool
    ) {
        hostEnvironment = TanyaAIHostEnvironment(locale: locale, colors: colors)
        self.isEnabled = isEnabled
        self.onNewConversation = onNewConversation
        self.onSend = onSend
    }

    /// Presents independently of the host navigation stack.
    /// Returns false when already open, offscreen, or another host modal is showing.
    @discardableResult
    public func present() -> Bool {
        present { EmptyView() }
    }

    /// Supplies a scrollable UI fixture or feature content, without changing host navigation.
    @discardableResult
    public func present<Content: View>(@ViewBuilder content: () -> Content) -> Bool {
        guard presented == nil, let presenter = availablePresenter() else { return false }
        let screen = HostEnvironmentReader(
            environment: hostEnvironment,
            content: ChatScreen(
                isEnabled: isEnabled, onBack: { [weak self] in self?.dismiss() },
                onNewConversation: onNewConversation, onSend: onSend, content: content
            )
        )
        .preferredColorScheme(.light)
        let controller = UIHostingController(rootView: screen)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = pushTransition
        pushTransition.interaction.attach(to: controller.view) { [weak self] in self?.dismiss() }
        presented = controller
        presenter.present(controller, animated: true)
        return true
    }

    /// Completion runs after the feature is gone, so the host can safely continue its own routing.
    /// Requests made while a dismissal is running wait for that dismissal instead of being dropped.
    public func dismiss(completion: (() -> Void)? = nil) {
        dismiss(isAnimated: true, completion: completion)
    }

    func attach(anchor: UIViewController) {
        self.anchor = anchor
    }

    /// Anchor hilang berarti root pemilik fitur (mis. main) sudah diganti; fitur ikut ditutup.
    func detach(anchor: UIViewController) {
        guard self.anchor === anchor else { return }
        self.anchor = nil
        dismiss(isAnimated: false, completion: nil)
    }
}

// MARK: - Helpers

private extension TanyaAIHost {
    func availablePresenter() -> UIViewController? {
        guard let anchor, anchor.viewIfLoaded?.window != nil else { return nil }
        var presenter = anchor
        while let parent = presenter.parent { presenter = parent }
        guard presenter.presentedViewController == nil, !presenter.isBeingDismissed else { return nil }
        return presenter
    }

    func dismiss(isAnimated: Bool, completion: (() -> Void)?) {
        guard let controller = presented else {
            completion?()
            return
        }
        if let completion { dismissCompletions.append(completion) }
        guard !controller.isBeingDismissed else { return }
        // Dismiss tanpa animasi tidak melewati animator; tampilkan kembali host di sini.
        controller.presentingViewController?.view.isHidden = false
        controller.dismiss(animated: isAnimated) { [weak self, weak controller] in
            self?.finishDismissal(of: controller)
        }
        // Swipe-back yang dibatalkan tidak menjalankan completion dismiss; lanjutkan permintaan yang tertunda.
        controller.transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] context in
            guard context.isCancelled else { return }
            DispatchQueue.main.async { self?.resumePendingDismissal() }
        }
    }

    func finishDismissal(of controller: UIViewController?) {
        // Completion routing hanya berjalan setelah fitur benar-benar lepas dari presenter.
        guard controller?.presentingViewController == nil else { return }
        if presented === controller { presented = nil }
        let completions = dismissCompletions
        dismissCompletions.removeAll()
        completions.forEach { $0() }
    }

    func resumePendingDismissal() {
        guard !dismissCompletions.isEmpty else { return }
        dismiss(isAnimated: true, completion: nil)
    }
}
