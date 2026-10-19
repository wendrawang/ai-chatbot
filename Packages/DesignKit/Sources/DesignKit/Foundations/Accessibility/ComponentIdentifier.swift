//
//  ComponentIdentifier.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

/// Identifier teknis untuk UI test, dikelompokkan per komponen seperti `CustomSizes`.
/// Nilainya kontrak dengan UI test; ubah hanya bersama test yang memakainya.
enum ComponentIdentifier {
    enum Header {
        static let root = "header"
        static let scrolled = "header.scrolled"
        static let title = "header.title"
        static let back = "header.back"
    }

    enum Composer {
        static let root = "composer"
        static let input = "composer.input"
        static let send = "composer.send"
        static let stop = "composer.stop"
    }

    enum Bubble {
        static let user = "bubble.user"
    }

    enum QuickAction {
        static let row = "quickAction.row"
    }

    enum Table {
        static let root = "table"
    }

    enum Option {
        static let list = "option.list"
    }

    enum Media {
        static let card = "media.card"
    }

    enum Action {
        static let button = "action.button"
        static let suggestions = "action.suggestions"
    }

    enum Status {
        static let indicator = "status.indicator"
        static let date = "status.date"
        static let scrollToLatest = "status.scrollToLatest"
    }
}
