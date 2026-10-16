//
//  ChatScreen.swift
//  TanyaAI
//
//  Created by Wendra on 15/10/26.
//

import DesignKit
import SwiftUI

/// The feature owns its header and draft. Content is injected; there is no chat/session model yet.
@MainActor
public struct ChatScreen<Content: View>: View {
    @Environment(\.locale)
    private var locale
    @Environment(\.dismiss)
    private var dismiss
    @Namespace
    private var scrollSpace
    @State
    private var text = InitialValues.emptyString
    @State
    private var isScrolled = false
    private let isEnabled: Bool
    private let onBack: (() -> Void)?
    private let onNewConversation: (() -> Void)?
    private let onSend: (String) -> Bool
    private let content: Content

    public init(
        isEnabled: Bool = InitialValues.isEnabled, onBack: (() -> Void)? = nil,
        onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.isEnabled = isEnabled
        self.onBack = onBack
        self.onNewConversation = onNewConversation
        self.onSend = onSend
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: InitialValues.zeroCGFloat) {
            conversation
            composer
        }
        .background(DefaultColorConstants().colorsSurfacePrimary.ignoresSafeArea())
    }

    private var conversation: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: InitialValues.zeroCGFloat) {
                    boundary
                    content
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
                        .padding(.top, headerHeight + FigmaSize.spacingLarge.scaledToArtwork)
                        .padding(.bottom, FigmaSize.spacingLarge.scaledToArtwork)
                }
            }
            .coordinateSpace(name: scrollSpace)
            .onPreferenceChange(ScrollBoundaryKey.self) { isScrolled = $0 }
            ScreenHeader(
                title: ChatCopy.title.text(locale: locale), backLabel: ChatCopy.back.text(locale: locale),
                isScrolled: isScrolled, onBack: close
            ) { moreMenu }
        }
    }

    private var boundary: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: ScrollBoundaryKey.self,
                value: geometry.frame(in: .named(scrollSpace)).minY < -CustomSizes.Layout.measurementTolerance
            )
        }
        .frame(height: InitialValues.zeroCGFloat)
        .accessibilityHidden(true)
    }

    private var moreMenu: some View {
        Menu {
            Button(ChatCopy.newConversation.text(locale: locale)) { onNewConversation?() }
                .disabled(onNewConversation == nil)
        } label: {
            SystemSymbol.more.image.resizable().scaledToFit()
                .rotationEffect(.degrees(CustomSizes.Header.moreRotation))
                .frame(
                    width: FigmaSize.weightIconSmall.scaledToArtwork,
                    height: FigmaSize.weightIconSmall.scaledToArtwork
                )
                .foregroundColor(DefaultColorConstants().colorsIconDark)
                .frame(
                    width: CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork,
                    height: CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork
                )
                .contentShape(Rectangle())
        }
        .accessibilityLabel(ChatCopy.more.text(locale: locale))
        .accessibilityIdentifier(ChatElementID.more)
    }

    private var composer: some View {
        MessageComposer(
            text: $text, placeholder: ChatCopy.placeholder.text(locale: locale),
            sendLabel: ChatCopy.send.text(locale: locale), isEnabled: isEnabled,
            onSend: submit
        )
        .padding(.horizontal, FigmaSize.spacingLarge.scaledToArtwork)
        .padding(.vertical, FigmaSize.spacingMedium.scaledToArtwork)
    }

    private var headerHeight: CGFloat {
        max(CustomSizes.Header.height.scaledToArtwork, CustomSizes.ActionButton.minimumTapSize.tapTargetInArtwork)
    }

    private func close() {
        if let onBack { onBack() } else { dismiss() }
    }

    private func submit() {
        guard onSend(text) else { return }
        text = InitialValues.emptyString
    }
}

extension ChatScreen where Content == EmptyView {
    /// Return true when the host accepts the submission; false preserves the draft.
    public init(
        isEnabled: Bool = InitialValues.isEnabled, onBack: (() -> Void)? = nil,
        onNewConversation: (() -> Void)? = nil, onSend: @escaping (String) -> Bool
    ) {
        self.init(
            isEnabled: isEnabled, onBack: onBack, onNewConversation: onNewConversation,
            onSend: onSend, content: { EmptyView() }
        )
    }
}

private struct ScrollBoundaryKey: PreferenceKey {
    // PreferenceKey requires this property name.
    // swiftlint:disable:next boolean_prefix
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = value || nextValue() }
}
