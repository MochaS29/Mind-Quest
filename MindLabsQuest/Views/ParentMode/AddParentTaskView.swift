import SwiftUI

struct AddParentTaskView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var category: TaskCategory = .lifeSkills
    @State private var verification: TaskVerification = .selfReport
    @State private var energyReward = 1
    @State private var bonusXP = 10
    @State private var bonusGold = 5
    @State private var isRecurring = false
    @State private var recurringDays: Set<Int> = []

    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var regionForCategory: MapRegion? {
        guard let regionId = RegionDatabase.categoryRegionMap[category] else { return nil }
        return RegionDatabase.region(byId: regionId)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    TextField("Description (optional)", text: $description)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.icon)
                                Text(cat.rawValue)
                            }
                            .tag(cat)
                        }
                    }

                    // Show linked region
                    if let region = regionForCategory {
                        HStack(spacing: 8) {
                            Image(systemName: region.icon)
                                .foregroundColor(region.biome.primaryColor)
                            Text("Unlocks: \(region.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Verification") {
                    Picker("How to verify", selection: $verification) {
                        ForEach(TaskVerification.allCases, id: \.self) { v in
                            HStack {
                                Image(systemName: v.icon)
                                Text(v.rawValue)
                            }
                            .tag(v)
                        }
                    }
                }

                Section("Rewards") {
                    Stepper("Travel Energy: \(energyReward)", value: $energyReward, in: 1...5)
                    Stepper("Bonus XP: \(bonusXP)", value: $bonusXP, in: 0...100, step: 5)
                    Stepper("Bonus Gold: \(bonusGold)", value: $bonusGold, in: 0...50, step: 5)
                }

                Section("Recurring") {
                    Toggle("Repeat weekly", isOn: $isRecurring)

                    if isRecurring {
                        HStack(spacing: 8) {
                            ForEach(Array(dayNames.enumerated()), id: \.offset) { index, name in
                                let dayNum = index + 1
                                Button {
                                    if recurringDays.contains(dayNum) {
                                        recurringDays.remove(dayNum)
                                    } else {
                                        recurringDays.insert(dayNum)
                                    }
                                } label: {
                                    Text(String(name.prefix(1)))
                                        .font(.caption.bold())
                                        .foregroundColor(recurringDays.contains(dayNum) ? .white : .gray)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(recurringDays.contains(dayNum) ? Color.mindLabsPurple : Color.gray.opacity(0.2))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveTask()
                }
                .disabled(title.isEmpty)
            )
        }
    }

    private func saveTask() {
        let regionId = RegionDatabase.categoryRegionMap[category]
        var task = ParentTask(
            title: title,
            description: description,
            category: category,
            isRecurring: isRecurring,
            recurringDays: recurringDays,
            verification: verification,
            energyReward: energyReward,
            bonusXP: bonusXP,
            bonusGold: bonusGold,
            mapRegionId: regionId
        )
        task.assignedDate = Date()
        gameManager.parentTaskManager.addTask(task)
        presentationMode.wrappedValue.dismiss()
    }
}
