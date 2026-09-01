import Foundation
import TanyaAIDomain
import XCTest
@testable import TanyaAIData

final class TanyaAIActionDecodingTests: XCTestCase {
    private let decoder = TanyaAIStreamEventDecoder()

    func testActionCardDecodesButtonsAndParameters() throws {
        let result = try decoder.decode(
            makeEvent(
                name: "content.actions",
                payload: [
                    "messageIdentifier": "actions-message",
                    "title": "Continue in the app",
                    "detail": "Sanitized detail",
                    "actions": [
                        [
                            "title": "Open transfer form",
                            "style": "primary",
                            "action": [
                                "identifier": "open-transfer",
                                "deeplink":
                                    "ocbcid://mobile?type=transfer"
                            ]
                        ],
                        [
                            "title": "Open statement",
                            "action": [
                                "identifier": "open-statement",
                                "deeplink": "ocbcid://mobile?type=statement"
                            ]
                        ]
                    ]
                ]
            )
        )

        guard case .content(let identifier, .actions(let payload)) = result else {
            return XCTFail("Expected action content")
        }
        XCTAssertEqual(identifier, "actions-message")
        XCTAssertEqual(payload.title, "Continue in the app")
        XCTAssertEqual(payload.buttons.count, 2)
        XCTAssertEqual(payload.buttons[0].style, .primary)
        XCTAssertEqual(
            payload.buttons[0].action.deeplink,
            "ocbcid://mobile?type=transfer"
        )
        XCTAssertEqual(payload.buttons[1].style, .primary)
        XCTAssertEqual(
            payload.buttons[1].action.deeplink,
            "ocbcid://mobile?type=statement"
        )
    }

    func testUnknownButtonStyleFallsBackToPrimary() throws {
        let result = try decoder.decode(
            makeEvent(
                name: "content.actions",
                payload: actionsPayload(style: "neon-glow")
            )
        )

        guard case .content(_, .actions(let payload)) = result else {
            return XCTFail("Expected action content")
        }
        XCTAssertEqual(payload.buttons[0].style, .primary)
    }

    /// An unparseable value must survive decoding so the host can reject it,
    /// rather than disappearing silently here.
    func testMalformedDeeplinkIsCarriedThroughForTheHostToReject() throws {
        var payload = approvalPayload()
        payload["handoff"] = [
            "identifier": "handoff-broken",
            "deeplink": "not a url at all"
        ]

        let result = try decoder.decode(
            makeEvent(name: "content.approval", payload: payload)
        )

        guard case .content(_, .approval(let approval)) = result else {
            return XCTFail("Expected approval content")
        }
        XCTAssertEqual(approval.handoff?.deeplink, "not a url at all")
    }

    func testEmptyActionListDegradesToUnsupportedContent() throws {
        let result = try decoder.decode(
            makeEvent(
                name: "content.actions",
                payload: [
                    "messageIdentifier": "actions-message",
                    "actions": []
                ]
            )
        )

        guard case .content(_, .unsupported(let message)) = result else {
            return XCTFail("Expected unsupported content")
        }
        XCTAssertEqual(
            message,
            "This action requires a newer app version."
        )
    }

    func testApprovalWithoutHandoffKeepsInFeatureAuthorization() throws {
        let result = try decoder.decode(
            makeEvent(name: "content.approval", payload: approvalPayload())
        )

        guard case .content(_, .approval(let payload)) = result else {
            return XCTFail("Expected approval content")
        }
        XCTAssertNil(payload.handoff)
    }

    func testApprovalHandoffDecodesTheDeeplinkUntouched() throws {
        var payload = approvalPayload()
        payload["handoff"] = [
            "identifier": "handoff-transfer",
            "deeplink": "ocbcid://mobile?type=transfer&amount=1250000"
        ]

        let result = try decoder.decode(
            makeEvent(name: "content.approval", payload: payload)
        )

        guard case .content(_, .approval(let approval)) = result else {
            return XCTFail("Expected approval content")
        }
        XCTAssertEqual(
            approval.handoff?.deeplink,
            "ocbcid://mobile?type=transfer&amount=1250000"
        )
    }

    private func actionsPayload(style: String) -> [String: Any] {
        [
            "messageIdentifier": "actions-message",
            "actions": [
                [
                    "title": "Open transfer form",
                    "style": style,
                    "action": [
                        "identifier": "open-transfer",
                        "deeplink": "ocbcid://mobile?type=transfer"
                    ]
                ]
            ]
        ]
    }

    private func approvalPayload() -> [String: Any] {
        [
            "messageIdentifier": "approval-message",
            "approvalIdentifier": "approval-1",
            "transactionIdentifier": "transaction-1",
            "challengeIdentifier": "challenge-1",
            "kind": "transfer",
            "title": "Confirm your transfer",
            "summary": [["label": "To", "value": "Sample"]],
            "expiresAt": "2099-01-01T00:00:00Z"
        ]
    }

    private func makeEvent(
        name: String,
        payload: [String: Any]
    ) -> TanyaAISSEEvent {
        let data = (try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.sortedKeys]
        )) ?? Data()
        return TanyaAISSEEvent(name: name, data: data)
    }
}
