//
//  TanyaAILink.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import Foundation

/// Link dari jawaban, sudah dikelompokkan. Host yang membuka: webview, handler deeplink,
/// atau telepon. Target berbahaya sudah ditolak parser sebelum sampai ke sini.
public enum TanyaAILink: Equatable {
    case web(URL)
    case deeplink(URL)
    case phone(URL)

    init(_ url: URL) {
        switch url.scheme?.lowercased() {
        case "http", "https": self = .web(url)
        case "tel", "telprompt": self = .phone(url)
        default: self = .deeplink(url)
        }
    }
}
