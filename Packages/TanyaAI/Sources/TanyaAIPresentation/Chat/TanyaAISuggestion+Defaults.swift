extension TanyaAISuggestion {
    static var sandboxDefaults: [TanyaAISuggestion] {
        [
            TanyaAISuggestion(
                identifier: "sample-portfolio",
                title: "Sample portfolio",
                prompt: "Show my sample portfolio"
            ),
            TanyaAISuggestion(
                identifier: "spending-insight",
                title: "Spending insight",
                prompt: "Show my spending insight"
            ),
            TanyaAISuggestion(
                identifier: "transfer-limit",
                title: "Transfer limit",
                prompt: "What is my transfer limit?"
            ),
            TanyaAISuggestion(
                identifier: "sample-transfer",
                title: "Sample transfer",
                prompt: "Create a sample transfer"
            ),
            TanyaAISuggestion(
                identifier: "currency-conversion",
                title: "Currency conversion",
                prompt: "Create currency conversion"
            ),
            TanyaAISuggestion(
                identifier: "time-deposit",
                title: "Time deposit",
                prompt: "Create time deposit"
            ),
            TanyaAISuggestion(
                identifier: "incoming-funds",
                title: "Incoming funds",
                prompt: "Show incoming funds"
            )
        ]
    }
}
