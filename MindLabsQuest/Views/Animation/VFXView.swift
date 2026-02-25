import SwiftUI

// MARK: - VFX View
// Renders any VFXEffect by dispatching to the appropriate backend view.
// Falls back to SwiftUIVFXView when optional backends (Lottie, Rive) are unavailable.

struct VFXView: View {
    let effect: VFXEffect
    var onComplete: (() -> Void)? = nil

    @State private var isAnimating = false

    var body: some View {
        resolvedView
            .allowsHitTesting(false)
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + effect.duration) {
                    isAnimating = false
                    onComplete?()
                }
            }
    }

    // MARK: - Backend Dispatch

    @ViewBuilder
    private var resolvedView: some View {
        switch effect.backend {
        case .swiftUI:
            SwiftUIVFXView(effectId: effect.id, color: effect.fallbackColor, duration: effect.duration)

        case .spriteSheet:
            SpriteSheetView(name: effect.assetName, duration: effect.duration)

        case .lottie:
            lottieView

        case .rive:
            riveView
        }
    }

    // MARK: - Lottie Backend

    @ViewBuilder
    private var lottieView: some View {
        #if canImport(Lottie)
        // When Lottie is available, use LottieView here.
        // For now, fall back to SwiftUI rendering.
        SwiftUIVFXView(effectId: effect.id, color: effect.fallbackColor, duration: effect.duration)
        #else
        SwiftUIVFXView(effectId: effect.id, color: effect.fallbackColor, duration: effect.duration)
        #endif
    }

    // MARK: - Rive Backend

    @ViewBuilder
    private var riveView: some View {
        #if canImport(RiveRuntime)
        // When RiveRuntime is available, use RiveViewModel here.
        // For now, fall back to SwiftUI rendering.
        SwiftUIVFXView(effectId: effect.id, color: effect.fallbackColor, duration: effect.duration)
        #else
        SwiftUIVFXView(effectId: effect.id, color: effect.fallbackColor, duration: effect.duration)
        #endif
    }
}

// MARK: - Preview

struct VFXView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VFXView(effect: VFXService.resolve("fire"))
                .frame(width: 200, height: 200)
        }
        .previewDisplayName("Fire VFX")
    }
}
