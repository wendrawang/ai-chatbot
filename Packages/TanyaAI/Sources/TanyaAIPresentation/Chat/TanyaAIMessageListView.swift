import SwiftUI

struct TanyaAIMessageListView: View {
    @ObservedObject var viewModel: TanyaAIChatViewModel

    @State private var bottomPosition = CGFloat.zero
    @State private var followsLatestMessage = true
    @State private var scrollRevision = 0

    private let bottomIdentifier = "chat.bottom"
    private let coordinateSpace = "chat.messageList"

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    messageStack
                }
                .coordinateSpace(name: coordinateSpace)
                .scrollDismissesKeyboard(.interactively)
                .simultaneousGesture(
                    followGesture(viewportHeight: geometry.size.height)
                )
                .onPreferenceChange(TanyaAIBottomPositionKey.self) {
                    bottomPosition = $0
                }
                .onChange(of: viewModel.messages.count) { _ in
                    requestScroll()
                }
                .onChange(of: viewModel.isGenerating) { _ in
                    requestScroll()
                }
                .onChange(of: viewModel.showsSuggestions) { _ in
                    requestScroll()
                }
                .onAppear {
                    requestScroll()
                }
                .task(id: scrollRevision) {
                    await scrollToBottom(using: scrollProxy)
                }
                .overlay {
                    latestMessageObserver
                }
                .tanyaAIAccessibilityIdentifier("chat.messageList")
            }
        }
    }

    private var messageStack: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.messages) { message in
                TanyaAIMessageRowView(
                    viewModel: message,
                    onApprovalEdit: viewModel.editApproval,
                    onApprovalCancel: viewModel.cancelApproval,
                    onApproval: viewModel.approve
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .id(message.id)
            }

            if viewModel.isGenerating {
                TanyaAITypingIndicatorView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }

            bottomAnchor
        }
        .padding(.vertical, 6)
    }

    private var bottomAnchor: some View {
        Color.clear
            .frame(height: 1)
            .id(bottomIdentifier)
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: TanyaAIBottomPositionKey.self,
                        value: proxy.frame(in: .named(coordinateSpace)).maxY
                    )
                }
            }
    }

    @ViewBuilder
    private var latestMessageObserver: some View {
        if let latestMessage = viewModel.messages.last {
            TanyaAILatestMessageObserver(message: latestMessage) {
                requestScroll()
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private func followGesture(viewportHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { _ in
                followsLatestMessage = false
            }
            .onEnded { _ in
                followsLatestMessage = bottomPosition <= viewportHeight + 80
            }
    }

    private func requestScroll() {
        guard followsLatestMessage else {
            return
        }
        scrollRevision &+= 1
    }

    @MainActor
    private func scrollToBottom(using proxy: ScrollViewProxy) async {
        try? await Task.sleep(nanoseconds: 50_000_000)
        for _ in 0..<3 {
            guard !Task.isCancelled, followsLatestMessage else {
                return
            }
            proxy.scrollTo(bottomIdentifier, anchor: .bottom)
            try? await Task.sleep(nanoseconds: 30_000_000)
        }
    }
}

private struct TanyaAIBottomPositionKey: PreferenceKey {
    static var defaultValue = CGFloat.zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct TanyaAILatestMessageObserver: View {
    @ObservedObject var message: TanyaAIMessageItemViewModel
    let onUpdate: () -> Void

    var body: some View {
        Color.clear
            .onReceive(message.objectWillChange) { _ in
                onUpdate()
            }
    }
}
