//
//  UIView+ScrollViews.swift
//  DesignKitTests
//
//  Created by Wendra on 13/11/26.
//

import UIKit

extension UIView {
    /// Semua scroll view di view ini dan turunannya, termasuk view ini sendiri.
    var scrollViews: [UIScrollView] {
        let own = (self as? UIScrollView).map { [$0] } ?? []
        return own + subviews.flatMap(\.scrollViews)
    }
}
