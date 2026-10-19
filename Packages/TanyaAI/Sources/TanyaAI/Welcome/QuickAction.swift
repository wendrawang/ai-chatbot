//
//  QuickAction.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import RswiftResources
import SwiftUI

/// Shortcut di welcome agar pengguna tidak bingung mau bertanya apa; mengetuk mengirim `prompt`.
enum QuickAction: CaseIterable, Identifiable {
    case portfolio, currency, reference

    var id: Self { self }

    var icon: Image {
        switch self {
        case .portfolio: return Image(R.image.portfolio)
        case .currency: return Image(R.image.currencyExchange)
        case .reference: return Image(R.image.referenceLetter)
        }
    }

    func title(locale: Locale) -> String {
        String(resource: copy.title, locale: locale)
    }

    func subtitle(locale: Locale) -> String {
        String(resource: copy.subtitle, locale: locale)
    }

    func prompt(locale: Locale) -> String {
        String(resource: copy.prompt, locale: locale)
    }
}

// MARK: - Helpers

private extension QuickAction {
    struct Copy {
        let title: StringResource
        let subtitle: StringResource
        let prompt: StringResource
    }

    var copy: Copy {
        let strings = R.string.localizable
        switch self {
        case .portfolio:
            return Copy(
                title: strings.quickPortfolioTitle, subtitle: strings.quickPortfolioSubtitle,
                prompt: strings.quickPortfolioPrompt
            )
        case .currency:
            return Copy(
                title: strings.quickCurrencyTitle, subtitle: strings.quickCurrencySubtitle,
                prompt: strings.quickCurrencyPrompt
            )
        case .reference:
            return Copy(
                title: strings.quickReferenceTitle, subtitle: strings.quickReferenceSubtitle,
                prompt: strings.quickReferencePrompt
            )
        }
    }
}
