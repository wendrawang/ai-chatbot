public extension Suggestion {
    static var sandboxDefaults: [Suggestion] {
        [
            Suggestion(
                identifier: "sample-portfolio",
                title: "Sample portfolio",
                prompt: "Show my sample portfolio"
            ),
            Suggestion(
                identifier: "spending-insight",
                title: "Spending insight",
                prompt: "Show my spending insight"
            ),
            Suggestion(
                identifier: "transfer-limit",
                title: "Transfer limit",
                prompt: "What is my transfer limit?"
            ),
            Suggestion(
                identifier: "sample-transfer",
                title: "Sample transfer",
                prompt: "Create a sample transfer"
            ),
            Suggestion(
                identifier: "currency-conversion",
                title: "Currency conversion",
                prompt: "Create currency conversion"
            ),
            Suggestion(
                identifier: "time-deposit",
                title: "Time deposit",
                prompt: "Create time deposit"
            ),
            Suggestion(
                identifier: "incoming-funds",
                title: "Incoming funds",
                prompt: "Show incoming funds"
            )
        ]
    }
}
