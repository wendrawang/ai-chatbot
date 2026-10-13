public extension ResponsePayload {
    func preservingInteraction(from previous: ResponsePayload?, isReadOnly: Bool) -> ResponsePayload {
        var result = self
        result.isReadOnly = self.isReadOnly || isReadOnly
        result.blocks = blocks.map { block in
            switch block {
            case .options(var options):
                if var prior = previous?.options(identifier: options.identifier) {
                    if prior.isReadOnly || prior.selectedIdentifier != nil {
                        prior.isReadOnly = true
                        return .options(prior)
                    }
                    options.selectedIdentifier = prior.selectedIdentifier ?? options.selectedIdentifier
                    options.isReadOnly = options.isReadOnly || prior.isReadOnly
                }
                options.isReadOnly = options.isReadOnly || result.isReadOnly
                return .options(options)
            case .documents(var documents):
                if let prior = previous?.documents(identifier: documents.identifier) {
                    let valid = Set(documents.documents.map(\.identifier))
                    documents.acceptedIdentifiers.formUnion(prior.acceptedIdentifiers.intersection(valid))
                    documents.isAuthorized = documents.isAuthorized || prior.isAuthorized
                }
                return .documents(documents)
            default: return block
            }
        }
        return result
    }

    func options(identifier: String) -> ResponseOptions? {
        for case .options(let options) in blocks where options.identifier == identifier { return options }
        return nil
    }

    func documents(identifier: String) -> ResponseDocuments? {
        for case .documents(let documents) in blocks where documents.identifier == identifier { return documents }
        return nil
    }
}
