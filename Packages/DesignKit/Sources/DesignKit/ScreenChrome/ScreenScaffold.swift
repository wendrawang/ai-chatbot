//
//  ScreenScaffold.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI

public struct ScreenScaffold<Content: View, Footer: View>: View
{
    private let content: Content
    private let footer: Footer
    public init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer)
    {
        self.content = content()
        self.footer = footer()
    }

    public var body: some View
    {
        content.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.background)
            .safeAreaInset(edge: .bottom, spacing: CGFloat(InitialValues.zero))
            {
                footer
            }
    }
}
