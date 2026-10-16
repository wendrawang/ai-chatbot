//
//  TransferFlowTests.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import TanyaAIDomain
@testable import TanyaAIFeature
import XCTest

@MainActor
final class TransferFlowTests: XCTestCase
{
    func testHappyFlowLocksRepeatedTapsAndReceiptUsesQuote() async
    {
        let fixture = TransferTestFixture()
        fixture.model.continueTapped()
        fixture.model.continueTapped()
        await fixture.settle()
        guard case let .reviewing(quote) = fixture.model.phase
        else
        {
            return XCTFail("Missing quote")
        }

        fixture.model.confirmTapped()
        fixture.model.authorizeCompleted()
        fixture.model.authorizeCompleted()
        await fixture.settle()
        guard case let .succeeded(receipt) = fixture.model.phase
        else
        {
            return XCTFail("Missing receipt")
        }

        XCTAssertEqual(receipt.quote, quote)
        XCTAssertEqual(receipt.quote.total.amount, 10000)
        XCTAssertEqual(receipt.quote.inquiry.draft.recipient, fixture.draft.recipient)
        let counts = await (fixture.service.inquiries, fixture.service.submits, fixture.authorizer.count)
        XCTAssertEqual(counts.0, 1)
        XCTAssertEqual(counts.1, 1)
        XCTAssertEqual(counts.2, 1)
    }

    func testInvalidAmountsNeverInvokeService() async
    {
        let fixture = TransferTestFixture()
        for amount in [nil, Decimal.zero, Decimal(-1), Decimal(25_000_001)]
        {
            fixture.model.updateAmount(amount)
            fixture.model.continueTapped()
        }

        let count = await fixture.service.inquiries
        XCTAssertEqual(count, 0)
        guard case .editing = fixture.model.phase
        else
        {
            return XCTFail("Should remain editing")
        }
    }

    func testInquiryRetryKeepsDraftAndEditInvalidatesQuote() async
    {
        let fixture = TransferTestFixture()
        await fixture.service.setFailing()
        fixture.model.updateNote("你好👨‍👩‍👧‍👦")
        fixture.model.continueTapped()
        await fixture.settle()
        XCTAssertEqual(fixture.model.phase.draft.note.count, 3)
        guard case .editing(_, .inquiryFailed) = fixture.model.phase
        else
        {
            return XCTFail("Missing error")
        }

        fixture.model.continueTapped()
        await fixture.settle()
        fixture.model.editTapped()
        fixture.model.updateAmount(20000)
        fixture.model.continueTapped()
        await fixture.settle()
        guard case let .reviewing(quote) = fixture.model.phase
        else
        {
            return XCTFail("Missing updated quote")
        }

        XCTAssertEqual(quote.amount.amount, 20000)
        let count = await fixture.service.inquiries
        XCTAssertEqual(count, 3)
    }

    func testPendingChecksStatusWithoutResubmitting() async
    {
        let fixture = TransferTestFixture()
        await fixture.service.setPending()
        fixture.model.continueTapped()
        await fixture.settle()
        fixture.model.confirmTapped()
        fixture.model.authorizeCompleted()
        await fixture.settle()
        guard case .pending = fixture.model.phase
        else
        {
            return XCTFail("Must remain pending")
        }

        fixture.model.authorizeCompleted()
        fixture.model.retryStatusCheck()
        fixture.model.retryStatusCheck()
        await fixture.settle()
        guard case let .succeeded(receipt) = fixture.model.phase
        else
        {
            return XCTFail("Missing status result")
        }

        XCTAssertEqual(receipt.reference, "DEMO-test")
        let counts = await (fixture.service.submits, fixture.service.checks)
        XCTAssertEqual(counts.0, 1)
        XCTAssertEqual(counts.1, 1)
    }
}
