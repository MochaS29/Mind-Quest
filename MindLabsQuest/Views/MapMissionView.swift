import SwiftUI

struct MapMissionView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var completedTaskId: UUID?
    @State private var showCompletionAnimation = false

    private var manager: ParentTaskManager {
        gameManager.parentTaskManager
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Progress header
                    progressHeader

                    // Pending missions
                    let pending = manager.todaysPendingTasks
                    if !pending.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Missions")
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(pending, id: \.id) { task in
                                missionCard(task)
                            }
                        }
                    }

                    // Completed missions
                    let completed = manager.todaysCompletedTasks
                    if !completed.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Completed")
                                .font(.headline)
                                .foregroundColor(.green)

                            ForEach(completed, id: \.id) { task in
                                completedMissionCard(task)
                            }
                        }
                    }

                    if manager.todaysTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "scroll")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No missions today")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Ask your parent to assign some tasks!")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.08, blue: 0.15),
                        Color(red: 0.12, green: 0.1, blue: 0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Map Missions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .overlay(
            Group {
                if showCompletionAnimation {
                    completionOverlay
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.3), value: showCompletionAnimation)
        )
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 12) {
            let progress = manager.gateProgress

            HStack {
                Text("Daily Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(progress.completed)/\(max(progress.required, manager.todaysTasks.count))")
                    .font(.title3.bold())
                    .foregroundColor(.orange)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)

                    let total = max(progress.required, manager.todaysTasks.count)
                    let fraction = total > 0 ? CGFloat(progress.completed) / CGFloat(total) : 0
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(fraction, 1.0), height: 12)
                }
            }
            .frame(height: 12)

            if !gameManager.isGameAccessible {
                Text("Complete \(max(0, manager.gateProgress.required - manager.gateProgress.completed)) more to unlock today's adventure!")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Mission Card

    private func missionCard(_ task: ParentTask) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Region icon
                if let regionId = task.mapRegionId, let region = RegionDatabase.region(byId: regionId) {
                    ZStack {
                        Circle()
                            .fill(region.biome.primaryColor.opacity(0.3))
                            .frame(width: 44, height: 44)
                        Image(systemName: region.icon)
                            .foregroundColor(region.biome.primaryColor)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(task.category.color.opacity(0.3))
                            .frame(width: 44, height: 44)
                        Text(task.category.icon)
                            .font(.title3)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    if let epic = task.epicTitle {
                        Text(epic)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                    Text(task.title)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Energy reward
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                    Text("+\(task.energyReward)")
                        .font(.caption.bold())
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.yellow.opacity(0.2)))
            }

            // Complete button
            Button {
                completeTask(task)
            } label: {
                HStack {
                    Image(systemName: task.verification.icon)
                    Text(completeButtonText(task))
                        .font(.subheadline.bold())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(task.verification == .parentConfirm)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(task.category.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func completedMissionCard(_ task: ParentTask) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .strikethrough()
                if let regionId = task.mapRegionId, let region = RegionDatabase.region(byId: regionId) {
                    Text("+\(task.energyReward) energy to \(region.name)")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.7))
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }

    // MARK: - Actions

    private func completeButtonText(_ task: ParentTask) -> String {
        switch task.verification {
        case .selfReport: return "Mark Complete"
        case .timerBased: return "Start Timer"
        case .parentConfirm: return "Awaiting Parent"
        }
    }

    private func completeTask(_ task: ParentTask) {
        completedTaskId = task.id
        gameManager.completeParentTask(task.id)
        showCompletionAnimation = true
        HapticService.notification(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCompletionAnimation = false
            completedTaskId = nil
        }
    }

    // MARK: - Completion Overlay

    private var completionOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)

                Text("Energy Earned!")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                if let taskId = completedTaskId,
                   let task = manager.tasks.first(where: { $0.id == taskId }),
                   let regionId = task.mapRegionId,
                   let region = RegionDatabase.region(byId: regionId) {
                    HStack(spacing: 6) {
                        Image(systemName: region.icon)
                            .foregroundColor(region.biome.primaryColor)
                        Text("+\(task.energyReward) to \(region.name)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    )
            )

            Spacer()
        }
        .background(Color.black.opacity(0.5).ignoresSafeArea())
    }
}
