import SwiftUI

/// Demo-only artwork rendered locally, with no external image dependency.
struct PreviewArtwork: View {
    let symbolName: String
    let tint: Color

    var body: some View {
        // TODO: Replace this dummy artwork with the approved Figma asset and load it from its owning bundle.
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [tint.opacity(0.6), tint], startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle().fill(Color.white.opacity(0.15))
                    .frame(width: geometry.size.width * 0.7)
                    .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3)
                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
