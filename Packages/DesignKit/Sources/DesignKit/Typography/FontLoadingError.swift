//
//  FontLoadingError.swift
//  DesignKit
//
//  Created by Wendra on 27/10/26.
//

import Foundation

/// Alasan `FontLoader` gagal mendaftarkan font.
public enum FontLoadingError: Error {
    case missingResource(String)
    case invalidFont(URL)
    case registration(URL)
}
