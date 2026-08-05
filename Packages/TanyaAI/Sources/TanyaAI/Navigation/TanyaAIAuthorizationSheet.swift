import TanyaAIDomain
import TanyaAIPresentation

struct TanyaAIAuthorizationSheet: Identifiable {
    let id: String
    let approval: TanyaAIApprovalPayload
    let viewModel: TanyaAIPINViewModel

    init(
        approval: TanyaAIApprovalPayload,
        viewModel: TanyaAIPINViewModel
    ) {
        id = approval.approvalIdentifier
        self.approval = approval
        self.viewModel = viewModel
    }
}
