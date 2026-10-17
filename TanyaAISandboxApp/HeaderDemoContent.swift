//
//  HeaderDemoContent.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI

/// Sandbox-only fixture for checking content under the header. Not a chat flow or bubble.
struct HeaderDemoContent: View {
    @Environment(\.locale)
    private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacingLarge.scaledToArtwork) {
            Text(String(resource: R.string.localizable.sandboxDemoTitle, locale: locale))
                .font(
                    Font(FontFace.firaSansSemiBold.font(size: FigmaSize.typographySizeDisplayNormal16.scaledToArtwork))
                )
                .accessibilityIdentifier(SandboxOptions.demoStartIdentifier)
            ForEach(InitialValues.zeroInteger..<SandboxOptions.demoParagraphCount, id: \.self) { _ in
                Text(String(resource: R.string.localizable.sandboxDemoBody, locale: locale))
            }
            Text(String(resource: R.string.localizable.sandboxDemoEnd, locale: locale))
                .accessibilityIdentifier(SandboxOptions.demoEndIdentifier)
        }
        .font(Font(FontFace.openSansRegular.font(size: FigmaSize.typographySizeDisplaySmall14.scaledToArtwork)))
        .foregroundColor(DefaultColorConstants().colorsTextPrimaryDark)
        .fixedSize(horizontal: false, vertical: true)
    }
}
