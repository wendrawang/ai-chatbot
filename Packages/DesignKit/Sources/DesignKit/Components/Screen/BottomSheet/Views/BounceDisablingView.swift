//
//  BounceDisablingView.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

import UIKit

/// View kosong yang mematikan bounce pada scroll view terdekat di atasnya, begitu ia masuk window, dan meneruskan
/// `isScrollEnabled` ke scroll view itu. Hanya scroll view itu yang berubah; scroll view lain di aplikasi tidak
/// tersentuh. Class karena butuh `didMoveToWindow` milik UIKit.
final class BounceDisablingView: UIView {
    var isScrollEnabled = true {
        didSet { configure() }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        configure()
    }
}

// MARK: - Helpers

private extension BounceDisablingView {
    var enclosingScrollView: UIScrollView? {
        sequence(first: superview, next: { $0?.superview })
            .compactMap { $0 as? UIScrollView }
            .first
    }

    func configure() {
        guard let scrollView = enclosingScrollView else { return }
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        guard scrollView.isScrollEnabled != isScrollEnabled else { return }
        scrollView.isScrollEnabled = isScrollEnabled
        guard !isScrollEnabled else { return }
        // Isi yang kembali muat tidak boleh tertinggal di posisi scroll lama.
        scrollView.contentOffset = CGPoint(x: .zero, y: -scrollView.adjustedContentInset.top)
    }
}
