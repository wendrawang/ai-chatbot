//
//  ScreenNavigationStyle.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import UIKit

public enum ScreenNavigationStyle
{
    public static func apply(to navigation: UINavigationController)
    {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.font: DesignTypography.heading()]
        let edge = UINavigationBarAppearance()
        edge.configureWithTransparentBackground()
        edge.backgroundColor = UIColor(CustomColors.background)
        edge.titleTextAttributes = appearance.titleTextAttributes
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = edge
        navigation.navigationBar.tintColor = UIColor(CustomColors.accent)
    }
}
