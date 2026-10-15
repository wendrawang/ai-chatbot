import TanyaAIContracts
import UIKit

/// Present an existing host page from the supplied controller without dismissing chat.
/// Call completion after that page has closed. It may arrive on any queue; the feature returns it to main.
public typealias TanyaAIHostFlowHandler = (
    TanyaAIHostFlowRequest,
    UIViewController,
    @escaping (Result<TanyaAIHostFlowResult, Error>) -> Void
) -> Void
