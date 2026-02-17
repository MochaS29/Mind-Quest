import SwiftUI

struct NewQuestView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var questTitle = ""
    @State private var questDescription = ""
    @State private var selectedCategory: TaskCategory = .academic
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var estimatedTime = 25
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Adventure Details") {
                    TextField("Adventure Title", text: $questTitle)
                    
                    TextField("Description (optional)", text: $questDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label {
                                Text(category.rawValue)
                            } icon: {
                                Text(category.icon)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.purple)
                        Text("Primary Stat Bonus: +\(selectedCategory.primaryStat.rawValue)")
                            .font(.caption)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Section("Difficulty & Time") {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            HStack {
                                Text(difficulty.rawValue)
                                Text("(+\(difficulty.xpReward) XP)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Stepper("Time: \(estimatedTime) minutes", value: $estimatedTime, in: 5...240, step: 5)
                }
                
                Section {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("Adventure Rewards") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                            Text("\(calculateXPReward()) XP")
                                .bold()
                            
                            if isClassBonus {
                                Text("(2x Class Bonus!)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                            Text("\(calculateXPReward() / 2) Gold")
                                .bold()
                        }
                        
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundColor(selectedCategory.primaryStat.color)
                            Text("+1 \(selectedCategory.primaryStat.rawValue)")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [.yellow.opacity(0.1), .orange.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Create New Adventure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createQuest()
                    }
                    .disabled(questTitle.isEmpty)
                }
            }
        }
    }
    
    var isClassBonus: Bool {
        guard let characterClass = gameManager.character.characterClass else { return false }
        return selectedCategory.primaryStat == characterClass.primaryStat
    }
    
    func calculateXPReward() -> Int {
        var reward = selectedDifficulty.xpReward
        if isClassBonus {
            reward *= 2
        }
        return reward
    }
    
    func createQuest() {
        let quest = Quest(
            title: questTitle,
            description: questDescription,
            category: selectedCategory,
            difficulty: selectedDifficulty,
            estimatedTime: estimatedTime,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        gameManager.addQuest(quest)
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewQuestView_Previews: PreviewProvider {
    static var previews: some View {
        NewQuestView()
            .environmentObject(GameManager())
    }
}