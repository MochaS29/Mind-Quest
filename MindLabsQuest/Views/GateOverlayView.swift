import SwiftUI

struct GateOverlayView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var messageIndex = 0

    private let encouragements = [
        "Complete your tasks to unlock today's adventure!",
        "Every task brings you closer to the map!",
        "Your quests await — finish your missions first!",
        "Real-world heroes unlock in-game power!",
        "Almost there — keep going!"
    ]

    private var manager: ParentTaskManager {
        gameManager.parentTaskManager
    }

    var body: some View {
        ZStack {
            // Semi-transparent overlay
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Lock icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)

                Text("Map Missions Required")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // Progress
                let progress = manager.gateProgress
                VStack(spacing: 8) {
                    Text("\(progress.completed) / \(progress.required) Tasks Completed")
                        .font(.headline)
                        .foregroundColor(.orange)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 16)

                            let fraction = progress.required > 0 ? CGFloat(progress.completed) / CGFloat(progress.required) : 0
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * min(fraction, 1.0), height: 16)
                        }
                    }
                    .frame(height: 16)
                    .padding(.horizontal, 40)
                }

                // Pending tasks
                VStack(spacing: 8) {
                    ForEach(manager.todaysPendingTasks.prefix(5), id: \.id) { task in
                        HStack(spacing: 8) {
                            Text(task.category.icon)

                            Text(task.epicTitle ?? task.title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Spacer()

                            if let regionId = task.mapRegionId, let region = RegionDatabase.region(byId: regionId) {
                                Image(systemName: region.icon)
                                    .font(.caption)
                                    .foregroundColor(region.biome.primaryColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.08))
                        )
                    }
                }
                .padding(.horizontal, 20)

                // Encouragement
                Text(encouragements[messageIndex % encouragements.count])
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Rotate messages
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                withAnimation {
                    messageIndex += 1
                }
            }
        }
    }
}
