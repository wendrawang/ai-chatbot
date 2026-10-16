//
//  TransferSafetyTests.swift
//  TanyaAIFeatureTests
//
//  Created by Wendra on 16/10/26.
//

import TanyaAIDomain
@testable import TanyaAIFeature
import XCTest

@MainActor
final class TransferSafetyTests: XCTestCase
{
    func testLateInquiryAfterCancellationIsIgnored() async
    {
        let fixture = TransferTestFixture()
        await fixture.service.setDelayed()
        fixture.model.continueTapped()
        let operation = fixture.model.operation
        for _ in 0 ..< 100
        {
            guard await fixture.service.continuation == nil
            else
            {
                break
            }

            await Task.yield()
        }

        let request = TransferInquiry(
            flowID: fixture.model.intent.flowID,
            sessionID: fixture.model.intent.sessionID,
            revision: fixture.model.revision,
            draft: fixture.draft)
        fixture.model.cancelTapped()
        await fixture.service.release(request)
        await operation?.value
        guard case .cancelled = fixture.model.phase
        else
        {
            return XCTFail("Late quote revived cancelled flow")
        }
    }

    func testRejectedPINCanRetryAndHistoryNeverRestoresAuthorization() async
    {
        let fixture = TransferTestFixture()
        await fixture.authorizer.rejectOnce()
        fixture.model.continueTapped()
        await fixture.settle()
        fixture.model.confirmTapped()
        fixture.model.authorizeCompleted()
        await fixture.settle()
        guard case .authorizing(let quote, false, true) = fixture.model.phase
        else
        {
            return XCTFail("Missing rejection")
        }

        let snapshot = TransferSnapshot(
            intent: fixture.model.intent,
            revision: fixture.model.revision,
            phase: fixture.model.phase)
        XCTAssertEqual(snapshot.phase, .reviewing(quote))
        fixture.model.authorizeCompleted()
        await fixture.settle()
        guard case .succeeded = fixture.model.phase
        else
        {
            return XCTFail("Retry failed")
        }

        let submits = await fixture.service.submits
        XCTAssertEqual(submits, 1)
    }

    func testPINBackPreservesQuoteAndNoteUsesGraphemes() async
    {
        let fixture = TransferTestFixture()
        fixture.model.updateNote(String(repeating: "👨‍👩‍👧‍👦", count: 30))
        XCTAssertEqual(fixture.model.phase.draft.note.count, 25)
        fixture.model.continueTapped()
        await fixture.settle()
        fixture.model.confirmTapped()
        fixture.model.pinBackTapped()
        guard case .reviewing = fixture.model.phase
        else
        {
            return XCTFail("Back should preserve review")
        }

        let count = await fixture.service.inquiries
        XCTAssertEqual(count, 1)
    }
}
