import SwiftUI

struct ParentTaskTemplatesView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode

    private let categories: [TaskCategory] = [.lifeSkills, .academic, .health, .fitness, .social, .creative]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(categories, id: \.self) { category in
                        categorySection(category)
                    }
                }
                .padding()
            }
            .navigationTitle("Task Templates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .mindLabsBackground()
        }
    }

    private func categorySection(_ category: TaskCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 8) {
                Text(category.icon)
                    .font(.title3)
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundColor(.mindLabsText)

                if let regionId = RegionDatabase.categoryRegionMap[category],
                   let region = RegionDatabase.region(byId: regionId) {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: region.icon)
                            .font(.caption)
                        Text(region.name)
                            .font(.caption)
                    }
                    .foregroundColor(region.biome.primaryColor)
                }
            }

            // Templates
            let templates = MapMissionDatabase.templates(for: category)
            ForEach(templates, id: \.id) { template in
                Button {
                    addTemplate(template)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(template.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.mindLabsText)
                            if let epic = template.epicTitle {
                                Text(epic)
                                    .font(.caption)
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("+\(template.energyReward)")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.yellow)

                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindLabsCard)
        )
    }

    private func addTemplate(_ template: ParentTask) {
        var task = template
        task.id = UUID()
        task.assignedDate = Date()
        gameManager.parentTaskManager.addTask(task)
        HapticService.notification(.success)
    }
}
