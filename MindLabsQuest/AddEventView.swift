import SwiftUI

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    let selectedDate: Date
    let onSave: (CalendarEvent) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var eventType: CalendarEvent.EventType = .assignment
    @State private var category: TaskCategory = .academic
    @State private var courseOrSubject = ""
    @State private var eventDate: Date
    @State private var priority: CalendarEvent.EventPriority = .medium
    @State private var estimatedTime = 60
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    
    init(selectedDate: Date, onSave: @escaping (CalendarEvent) -> Void) {
        self.selectedDate = selectedDate
        self.onSave = onSave
        _eventDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Event Title", text: $title)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    TextField("Course/Subject (optional)", text: $courseOrSubject)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    TextField("Description (optional)", text: $description)
                        .textFieldStyle(MindLabsTextFieldStyle())
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Event Type") {
                    Picker("Type", selection: $eventType) {
                        ForEach(CalendarEvent.EventType.allCases, id: \.self) { type in
                            Label {
                                Text(type.rawValue)
                            } icon: {
                                Text(type.icon)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.mindLabsPurple)
                    
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { cat in
                            Label {
                                Text(cat.rawValue)
                            } icon: {
                                Text(cat.icon)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Priority & Time") {
                    // Priority Selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Priority Level")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack(spacing: 10) {
                            ForEach(CalendarEvent.EventPriority.allCases, id: \.self) { prio in
                                PriorityButton(
                                    priority: prio,
                                    isSelected: priority == prio,
                                    action: { priority = prio }
                                )
                            }
                        }
                    }
                    
                    // Time Estimate
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Estimated Time:")
                            Text("\(estimatedTime) minutes")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsPurple)
                        }
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        
                        Slider(value: Binding(
                            get: { Double(estimatedTime) },
                            set: { estimatedTime = Int($0) }
                        ), in: 15...240, step: 15)
                        .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Date & Time") {
                    DatePicker("Event Date", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Reminder") {
                    Toggle("Set Reminder", isOn: $hasReminder)
                        .tint(.mindLabsPurple)
                    
                    if hasReminder {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Preview Section
                Section("Quest Preview") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This event will create a quest worth:")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        HStack {
                            Label("\(calculateXP()) XP", systemImage: "star.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsBlue)
                            
                            Spacer()
                            
                            Label("\(calculateGold()) Gold", systemImage: "bitcoinsign.circle.fill")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.yellow)
                        }
                        
                        Text("Difficulty: \(eventType.defaultDifficulty.rawValue)")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding(.vertical, 5)
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.mindLabsPurple),
            
            trailing: Button("Save") {
                saveEvent()
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(title.isEmpty)
            .foregroundColor(title.isEmpty ? .mindLabsTextLight : .mindLabsPurple)
        )
    }
    
    private func calculateXP() -> Int {
        let baseXP = eventType.defaultDifficulty.xpReward
        return Int(Double(baseXP) * priority.xpMultiplier)
    }
    
    private func calculateGold() -> Int {
        let baseGold = calculateXP() / 2
        return baseGold
    }
    
    private func saveEvent() {
        let event = CalendarEvent(
            title: title,
            description: description,
            date: eventDate,
            duration: estimatedTime,
            eventType: eventType,
            category: category,
            priority: priority,
            courseOrSubject: courseOrSubject,
            location: "",
            reminder: hasReminder ? .fifteenMinutes : nil
        )
        
        onSave(event)
    }
}

struct PriorityButton: View {
    let priority: CalendarEvent.EventPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(priority.color)
                    .frame(width: 12, height: 12)
                
                Text(priority.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(isSelected ? priority.color : .mindLabsTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? priority.color.opacity(0.2) : Color.mindLabsBorder.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? priority.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(selectedDate: Date()) { _ in }
    }
}