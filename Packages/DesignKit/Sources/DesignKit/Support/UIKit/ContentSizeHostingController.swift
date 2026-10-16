//
//  ContentSizeHostingController.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import UIKit

/// iOS15 has no sizingOptions: propagate measured content height through one owner.
public final class ContentSizeHostingController<Content: View>: UIHostingController<Content>
{
    public var onHeightChange: ((CGFloat) -> Void)?
    private var measuredHeight: CGFloat = 0
    override public func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        guard view.bounds.width > 0
        else
        {
            return
        }

        let size = sizeThatFits(in: CGSize(width: view.bounds.width, height: .greatestFiniteMagnitude))
        guard abs(size.height - measuredHeight) > CustomSizes.measurementTolerance
        else
        {
            return
        }

        measuredHeight = size.height
        onHeightChange?(ceil(size.height))
    }
}
