//
//  UINavigationController+PopGesture.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import UIKit

/// Salinan extension global host: swipe-back tetap aktif walaupun nav bar disembunyikan.
/// `@retroactive` (Xcode 15.3+) menandai conformance ke tipe UIKit secara eksplisit.
extension UINavigationController {
    private(set) static var isPopGestureEnabled = true

    static func setPopGestureEnabled(_ isEnabled: Bool = true) {
        isPopGestureEnabled = isEnabled
    }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Sama dengan host: hanya bila ada halaman untuk kembali.
        UINavigationController.isPopGestureEnabled && !viewControllers.dropFirst().isEmpty
    }
}
