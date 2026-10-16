//
//  FontLoader.swift
//  DesignKit
//
//  Created by Wendra on 16/10/26.
//

import CoreText
import Foundation

public enum FontLoader
{
    private static let registration: Void =
    {
        let urls = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        for url in urls
        {
            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            _ = error?.takeRetainedValue()
        }
    }()

    public static func registerFonts()
    {
        _ = registration
    }
}
