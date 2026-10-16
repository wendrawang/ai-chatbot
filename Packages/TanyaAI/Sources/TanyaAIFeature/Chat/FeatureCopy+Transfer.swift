//
//  FeatureCopy+Transfer.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Foundation
import RswiftResources

extension FeatureCopy
{
    var sendGreeting: String
    {
        text(R.string.localizable.sendGreeting)
    }

    var method: String
    {
        text(R.string.localizable.method)
    }

    var note: String
    {
        text(R.string.localizable.note)
    }

    func noteCount(_ value0: Int, _ value1: Int) -> String
    {
        String(
            format: R.string.localizable.noteCount,
            preferredLanguages: [language],
            value0,
            value1)
    }

    var now: String
    {
        text(R.string.localizable.now)
    }

    var pending: String
    {
        text(R.string.localizable.pending)
    }

    var pickerTitle: String
    {
        text(R.string.localizable.pickerTitle)
    }

    func pinHelp(_ value0: Int) -> String
    {
        String(
            format: R.string.localizable.pinHelp,
            preferredLanguages: [language],
            value0)
    }

    func pinProgress(_ value0: Int, _ value1: Int) -> String
    {
        String(
            format: R.string.localizable.pinProgress,
            preferredLanguages: [language],
            value0,
            value1)
    }

    var pinRejected: String
    {
        text(R.string.localizable.pinRejected)
    }

    var pinTitle: String
    {
        text(R.string.localizable.pinTitle)
    }

    var placeholder: String
    {
        text(R.string.localizable.placeholder)
    }

    var purpose: String
    {
        text(R.string.localizable.purpose)
    }

    var range: String
    {
        text(R.string.localizable.range)
    }

    var receiptTitle: String
    {
        text(R.string.localizable.receiptTitle)
    }

    var recipient: String
    {
        text(R.string.localizable.recipient)
    }

    var recurring: String
    {
        text(R.string.localizable.recurring)
    }

    var reference: String
    {
        text(R.string.localizable.reference)
    }

    var required: String
    {
        text(R.string.localizable.required)
    }

    var scheduled: String
    {
        text(R.string.localizable.scheduled)
    }

    var send: String
    {
        text(R.string.localizable.send)
    }

    var share: String
    {
        text(R.string.localizable.share)
    }

    var source: String
    {
        text(R.string.localizable.sourceAccount)
    }

    var statusFailed: String
    {
        text(R.string.localizable.statusFailed)
    }

    var submitting: String
    {
        text(R.string.localizable.submitting)
    }

    var summaryTitle: String
    {
        text(R.string.localizable.summaryTitle)
    }

    var time: String
    {
        text(R.string.localizable.time)
    }

    var title: String
    {
        text(R.string.localizable.title)
    }

    var total: String
    {
        text(R.string.localizable.total)
    }

    var transfer: String
    {
        text(R.string.localizable.transfer)
    }

    var transferDate: String
    {
        text(R.string.localizable.transferDate)
    }

    var unavailable: String
    {
        text(R.string.localizable.unavailable)
    }
}
