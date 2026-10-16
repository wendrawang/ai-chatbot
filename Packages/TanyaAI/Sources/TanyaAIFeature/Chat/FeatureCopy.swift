//
//  FeatureCopy.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import RswiftResources

struct FeatureCopy
{
    let language: String

    var latest: String
    {
        text(R.string.localizable.latest)
    }

    var locale: Locale
    {
        Locale(identifier: language)
    }

    func text(_ resource: StringResource) -> String
    {
        String(resource: resource, preferredLanguages: [language])
    }

    var additional: String
    {
        text(R.string.localizable.additional)
    }

    var amount: String
    {
        text(R.string.localizable.amount)
    }

    var amountTitle: String
    {
        text(R.string.localizable.amountTitle)
    }

    var back: String
    {
        text(R.string.localizable.back)
    }

    func benefit(_ value0: Int, _ value1: Int) -> String
    {
        String(
            format: R.string.localizable.benefit,
            preferredLanguages: [language],
            value0,
            value1)
    }

    var busyFlow: String
    {
        text(R.string.localizable.busyFlow)
    }

    var cancel: String
    {
        text(R.string.localizable.cancel)
    }

    var cancelled: String
    {
        text(R.string.localizable.cancelled)
    }

    var change: String
    {
        text(R.string.localizable.change)
    }

    var checkStatus: String
    {
        text(R.string.localizable.checkStatus)
    }

    var close: String
    {
        text(R.string.localizable.close)
    }

    var confirm: String
    {
        text(R.string.localizable.confirm)
    }

    var connectionFailed: String
    {
        text(R.string.localizable.connectionFailed)
    }

    var continueAction: String
    {
        text(R.string.localizable.continueAction)
    }

    var currency: String
    {
        text(R.string.localizable.currency)
    }

    var date: String
    {
        text(R.string.localizable.date)
    }

    var delete: String
    {
        text(R.string.localizable.delete)
    }

    var demo: String
    {
        text(R.string.localizable.demo)
    }

    var done: String
    {
        text(R.string.localizable.done)
    }

    var edit: String
    {
        text(R.string.localizable.edit)
    }

    var fee: String
    {
        text(R.string.localizable.fee)
    }

    var fundTransfer: String
    {
        text(R.string.localizable.fundTransfer)
    }

    var inquiring: String
    {
        text(R.string.localizable.inquiring)
    }

    var inquiryFailed: String
    {
        text(R.string.localizable.inquiryFailed)
    }
}
