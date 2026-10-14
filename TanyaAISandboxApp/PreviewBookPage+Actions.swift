import DesignKit
import SwiftUI

extension PreviewBookPage {
    var actionSamples: some View {
        VStack(alignment: .leading, spacing: FigmaSize.spacing32.sizeInArtwork) {
            sample("Outlined: vertical actions") {
                ForEach(PreviewBookSamples.suggestions, id: \.self) { title in
                    ActionPill(title: title, symbolName: "arrow.turn.down.right") { feedback = title }
                }
                ActionPill(title: "Disabled action", isEnabled: false) {}
            }
            sample("Horizontal suggestions") {
                SuggestionList {
                    ForEach(PreviewBookSamples.suggestions, id: \.self) { title in
                        ActionPill(title: title) { feedback = title }
                    }
                }
                .accessibilityIdentifier("preview.suggestions")
            }
            sample("Underlined redirect") {
                LinkAction(title: "Buka informasi produk") { feedback = "Callback destination ke host" }
                LinkAction(title: "Disabled link", isEnabled: false) {}
            }
            sample("Filled CTA: accent & custom tint") {
                FilledAction(
                    title: "Optimize now", onTap: { feedback = "Optimize now" },
                    icon: {
                        Image(systemName: "sparkles").resizable().scaledToFit()
                    })
                FilledAction(
                    title: "Optimize now", tint: .blue, onTap: { feedback = "Optimize now blue" },
                    icon: {
                        Image(systemName: "sparkles").resizable().scaledToFit()
                    })
                FilledAction(
                    title: PreviewBookSamples.longText, isEnabled: false, onTap: {},
                    icon: {
                        Image(systemName: "sparkles").resizable().scaledToFit()
                    })
            }
        }
    }
}
