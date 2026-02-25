import SwiftUI

// MARK: - Sprite Sheet View
// Frame-by-frame animation player for sprite sheet assets.
// Looks for images named "{name}_01", "{name}_02", etc. in the asset catalog.
// If no frames are found, renders nothing (the caller handles fallback via VFXView).

struct SpriteSheetView: View {
    let name: String       // Base asset name (e.g., "vfx_fire")
    let duration: Double   // Total animation duration in seconds

    @State private var currentFrame: Int = 0
    @State private var frames: [UIImage] = []
    @State private var timer: Timer? = nil

    var body: some View {
        Group {
            if frames.isEmpty {
                // No frames found; render nothing. VFXView handles fallback.
                EmptyView()
            } else {
                Image(uiImage: frames[currentFrame])
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            loadFrames()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }

    // MARK: - Frame Loading

    /// Scans the asset catalog for sequential frames: name_01, name_02, ..., name_99.
    private func loadFrames() {
        var loadedFrames: [UIImage] = []
        var frameIndex = 1

        while frameIndex < 100 {
            let frameName = String(format: "%@_%02d", name, frameIndex)
            if let image = UIImage(named: frameName) {
                loadedFrames.append(image)
                frameIndex += 1
            } else {
                break
            }
        }

        frames = loadedFrames
    }

    // MARK: - Animation Control

    /// Starts a repeating timer that cycles through frames at the appropriate interval.
    private func startAnimation() {
        guard frames.count > 1 else { return }

        let interval = duration / Double(frames.count)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % frames.count
        }
    }

    /// Invalidates the frame timer.
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview

struct SpriteSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteSheetView(name: "vfx_fire", duration: 1.0)
            .frame(width: 200, height: 200)
            .background(Color.black)
            .previewDisplayName("Sprite Sheet")
    }
}
