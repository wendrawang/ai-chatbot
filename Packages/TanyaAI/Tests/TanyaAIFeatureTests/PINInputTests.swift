// Created by Wendra on 16/10/26.

@testable import TanyaAIFeature
import XCTest

@MainActor
final class PINInputTests: XCTestCase
{
    func testCompleteChallengeClearsDigitsAndLocksDuplicateCompletion()
    {
        var count = 0
        let input = PINInput(length: 6)
        {
            count += 1
        }

        for number in 0 ..< 20
        {
            input.append(number % 10)
        }

        XCTAssertEqual(count, 1)
        XCTAssertTrue(input.digits.isEmpty)
        input.clear()
        for number in 0 ..< 6
        {
            input.append(number)
        }

        XCTAssertEqual(count, 2)
    }

    func testDeleteAndLeavingClearTransientDigits()
    {
        let input = PINInput(length: 6)
        {
            XCTFail("Incomplete challenge must not complete")
        }

        input.append(8)
        input.append(9)
        input.delete()
        XCTAssertEqual(input.digits.count, 1)
        input.clear()
        XCTAssertTrue(input.digits.isEmpty)
    }
}
