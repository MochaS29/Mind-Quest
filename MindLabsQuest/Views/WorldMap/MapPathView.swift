import SwiftUI

struct MapPathView: View {
    let regions: [MapRegion]
    let unlockedIds: Set<String>
    let mapSize: CGSize

    var body: some View {
        Canvas { context, size in
            for region in regions {
                for connectedId in region.connectedRegionIds {
                    // Only draw once per pair (alphabetical order)
                    guard region.id < connectedId else { continue }
                    guard let connected = regions.first(where: { $0.id == connectedId }) else { continue }

                    let from = CGPoint(
                        x: region.position.x * size.width,
                        y: region.position.y * size.height
                    )
                    let to = CGPoint(
                        x: connected.position.x * size.width,
                        y: connected.position.y * size.height
                    )

                    let bothUnlocked = unlockedIds.contains(region.id) && unlockedIds.contains(connectedId)
                    let eitherDiscovered = true // Always draw if we're iterating

                    var path = Path()
                    // Bezier curve for a more organic look
                    let midY = (from.y + to.y) / 2
                    let controlOffset = abs(from.x - to.x) * 0.15
                    path.move(to: from)
                    path.addCurve(
                        to: to,
                        control1: CGPoint(x: from.x, y: midY - controlOffset),
                        control2: CGPoint(x: to.x, y: midY + controlOffset)
                    )

                    if bothUnlocked {
                        context.stroke(
                            path,
                            with: .color(.white.opacity(0.4)),
                            lineWidth: 2.5
                        )
                    } else if eitherDiscovered {
                        context.stroke(
                            path,
                            with: .color(.gray.opacity(0.15)),
                            lineWidth: 1.5
                        )
                    }
                }
            }
        }
    }
}

// Fallback for iOS 15 where Canvas is iOS 15+, but let's also provide a Path-based version
struct MapPathFallbackView: View {
    let regions: [MapRegion]
    let unlockedIds: Set<String>

    var body: some View {
        GeometryReader { geo in
            ForEach(pathPairs, id: \.id) { pair in
                pair.path(in: geo.size)
                    .stroke(
                        pair.bothUnlocked ? Color.white.opacity(0.4) : Color.gray.opacity(0.15),
                        lineWidth: pair.bothUnlocked ? 2.5 : 1.5
                    )
            }
        }
    }

    private var pathPairs: [PathPair] {
        var pairs: [PathPair] = []
        for region in regions {
            for connectedId in region.connectedRegionIds {
                guard region.id < connectedId else { continue }
                guard let connected = regions.first(where: { $0.id == connectedId }) else { continue }
                let bothUnlocked = unlockedIds.contains(region.id) && unlockedIds.contains(connectedId)
                pairs.append(PathPair(
                    id: "\(region.id)_\(connectedId)",
                    from: region.position,
                    to: connected.position,
                    bothUnlocked: bothUnlocked
                ))
            }
        }
        return pairs
    }
}

struct PathPair: Identifiable {
    let id: String
    let from: MapPosition
    let to: MapPosition
    let bothUnlocked: Bool

    func path(in size: CGSize) -> Path {
        let fromPt = CGPoint(x: from.x * size.width, y: from.y * size.height)
        let toPt = CGPoint(x: to.x * size.width, y: to.y * size.height)
        let midY = (fromPt.y + toPt.y) / 2
        let controlOffset = abs(fromPt.x - toPt.x) * 0.15

        var p = Path()
        p.move(to: fromPt)
        p.addCurve(
            to: toPt,
            control1: CGPoint(x: fromPt.x, y: midY - controlOffset),
            control2: CGPoint(x: toPt.x, y: midY + controlOffset)
        )
        return p
    }
}
