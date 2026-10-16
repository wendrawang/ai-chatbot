//
//  HarnessCopy.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import RswiftResources

public struct HarnessCopy
{
    let language: String
    var locale: Locale
    {
        Locale(identifier: language)
    }

    func text(_ resource: StringResource) -> String
    {
        String(resource: resource, preferredLanguages: [language])
    }

    var demo: String
    {
        text(R.string.localizable.demo)
    }

    var destination: String
    {
        text(R.string.localizable.destination)
    }

    var done: String
    {
        text(R.string.localizable.done)
    }

    var duplicateScenario: String
    {
        text(R.string.localizable.duplicateScenario)
    }

    var fallback: String
    {
        text(R.string.localizable.fallback)
    }

    var greeting: String
    {
        text(R.string.localizable.intro)
    }

    var historyNotice: String
    {
        text(R.string.localizable.historyNotice)
    }

    var inquiryScenario: String
    {
        text(R.string.localizable.inquiryScenario)
    }

    var languageLabel: String
    {
        text(R.string.localizable.language)
    }

    var lateScenario: String
    {
        text(R.string.localizable.lateScenario)
    }

    var newDemo: String
    {
        text(R.string.localizable.newDemo)
    }

    var openChat: String
    {
        text(R.string.localizable.openChat)
    }

    var pendingScenario: String
    {
        text(R.string.localizable.pendingScenario)
    }

    var pinScenario: String
    {
        text(R.string.localizable.pinScenario)
    }

    var resume: String
    {
        text(R.string.localizable.resume)
    }

    var scenario: String
    {
        text(R.string.localizable.scenario)
    }

    var successScenario: String
    {
        text(R.string.localizable.successScenario)
    }
}
