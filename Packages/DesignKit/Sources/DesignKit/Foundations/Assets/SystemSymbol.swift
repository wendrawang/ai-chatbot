//
//  SystemSymbol.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import SwiftUI

public enum SystemSymbol: String {
    // TODO: Replace with the approved send artwork exported from Figma.
    case send = "arrow.up"
    // TODO: Replace navigation symbols with the approved Figma artwork.
    case back = "chevron.left"
    case more = "ellipsis"

    public var image: Image { Image(systemName: rawValue) }
}
