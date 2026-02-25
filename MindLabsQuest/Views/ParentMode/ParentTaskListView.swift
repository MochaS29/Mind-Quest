import SwiftUI

struct ParentTaskListView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showAddTask = false
    @State private var showTemplates = false

    private var manager: ParentTaskManager {
        gameManager.parentTaskManager
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Enable/Disable toggle
                enableToggle

                if manager.settings.isEnabled {
                    // Gate settings
                    gateSettings

                    // Today's tasks
                    todaysTasksSection

                    // Add buttons
                    addButtons

                    // Task history
                    historySection
                }
            }
            .padding()
        }
        .sheet(isPresented: $showAddTask) {
            AddParentTaskView()
                .environmentObject(gameManager)
        }
        .sheet(isPresented: $showTemplates) {
            ParentTaskTemplatesView()
                .environmentObject(gameManager)
        }
    }

    // MARK: - Enable Toggle

    private var enableToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Parent Task System")
                    .font(.headline)
                    .foregroundColor(.mindLabsText)
                Text("Assign real-world tasks that unlock map regions")
                    .font(.caption)
                    .foregroundColor(.mindLabsTextSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { manager.settings.isEnabled },
                set: { newValue in
                    manager.settings.isEnabled = newValue
                    manager.saveData()
                }
            ))
            .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindLabsCard)
        )
    }

    // MARK: - Gate Settings

    private var gateSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gate Mode")
                .font(.headline)
                .foregroundColor(.mindLabsText)

            Picker("Gate Mode", selection: Binding(
                get: { manager.settings.gateMode },
                set: { newValue in
                    manager.settings.gateMode = newValue
                    manager.saveData()
                }
            )) {
                ForEach(GateMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Text(manager.settings.gateMode.description)
                .font(.caption)
                .foregroundColor(.mindLabsTextSecondary)

            if manager.settings.gateMode == .soft {
                HStack {
                    Text("Tasks required:")
                        .font(.subheadline)
                        .foregroundColor(.mindLabsText)
                    Spacer()
                    Stepper("\(manager.settings.softGateThreshold)", value: Binding(
                        get: { manager.settings.softGateThreshold },
                        set: { newValue in
                            manager.settings.softGateThreshold = newValue
                            manager.saveData()
                        }
                    ), in: 1...10)
                    .foregroundColor(.mindLabsText)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindLabsCard)
        )
    }

    // MARK: - Today's Tasks

    private var todaysTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Tasks")
                    .font(.headline)
                    .foregroundColor(.mindLabsText)
                Spacer()
                Text("\(manager.todaysCompletedTasks.count)/\(manager.todaysTasks.count)")
                    .font(.subheadline.bold())
                    .foregroundColor(.mindLabsPurple)
            }

            if manager.todaysTasks.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.gray)
                    Text("No tasks assigned for today")
                        .foregroundColor(.mindLabsTextSecondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(manager.todaysTasks, id: \.id) { task in
                    taskRow(task)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindLabsCard)
        )
    }

    private func taskRow(_ task: ParentTask) -> some View {
        HStack(spacing: 12) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .gray)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.mindLabsText)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {
                    Text(task.category.icon)
                    if let regionId = task.mapRegionId, let region = RegionDatabase.region(byId: regionId) {
                        Text(region.name)
                            .font(.caption)
                            .foregroundColor(region.biome.primaryColor)
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text("+\(task.energyReward)")
                            .font(.caption)
                    }
                    .foregroundColor(.yellow)
                }
            }

            Spacer()

            // Delete button
            Button {
                manager.deleteTask(task.id)
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Add Buttons

    private var addButtons: some View {
        HStack(spacing: 12) {
            Button {
                showAddTask = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Task")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mindLabsPurple)
                )
            }

            Button {
                showTemplates = true
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc.fill")
                    Text("Templates")
                }
                .font(.subheadline.bold())
                .foregroundColor(.mindLabsPurple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.mindLabsPurple, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed Tasks")
                .font(.headline)
                .foregroundColor(.mindLabsText)

            let completed = manager.tasks.filter { $0.isCompleted }.sorted { ($0.completedAt ?? Date.distantPast) > ($1.completedAt ?? Date.distantPast) }.prefix(10)

            if completed.isEmpty {
                Text("No completed tasks yet")
                    .font(.caption)
                    .foregroundColor(.mindLabsTextSecondary)
            } else {
                ForEach(Array(completed), id: \.id) { task in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(task.title)
                            .font(.caption)
                            .foregroundColor(.mindLabsTextSecondary)
                        Spacer()
                        if let date = task.completedAt {
                            Text(date, style: .date)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mindLabsCard)
        )
    }
}
