import SwiftUI

struct AddRecurringEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var calendarManager = CalendarManager.shared
    
    let onSave: (CalendarEvent) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var category: TaskCategory = .academic
    @State private var eventType: CalendarEvent.EventType = .assignment
    @State private var date = Date()
    @State private var duration = 30
    @State private var location = ""
    @State private var attendees: [String] = []
    @State private var newAttendee = ""
    
    // Recurrence settings
    @State private var isRecurring = false
    @State private var recurrenceFrequency: RecurrenceRule.Frequency = .weekly
    @State private var recurrenceInterval = 1
    @State private var recurrenceEndType: RecurrenceEndType = .never
    @State private var recurrenceEndDate = Date()
    @State private var recurrenceCount = 10
    @State private var selectedWeekdays: Set<Int> = []
    @State private var monthlyRecurrenceType: MonthlyRecurrenceType = .sameDay
    @State private var weekOfMonth = 1
    @State private var dayOfWeek = 1
    
    enum RecurrenceEndType: String, CaseIterable {
        case never = "Never"
        case onDate = "On Date"
        case afterOccurrences = "After Occurrences"
    }
    
    enum MonthlyRecurrenceType: String, CaseIterable {
        case sameDay = "Same Day Each Month"
        case weekday = "Same Weekday"
    }
    
    var body: some View {
        NavigationView {
            Form {
                eventDetailsSection
                dateTimeSection
                locationAttendeesSection
                recurrenceSection
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    // MARK: - Form Sections
    
    var eventDetailsSection: some View {
        Section(header: Text("Event Details")) {
            TextField("Title", text: $title)
            
            TextField("Description", text: $description)
            
            Picker("Category", selection: $category) {
                ForEach(TaskCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            
            Picker("Type", selection: $eventType) {
                ForEach(CalendarEvent.EventType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        }
    }
    
    var dateTimeSection: some View {
        Section(header: Text("Date & Time")) {
            DatePicker("Start", selection: $date)
            
            HStack {
                Text("Duration")
                Spacer()
                Picker("", selection: $duration) {
                    Text("15 min").tag(15)
                    Text("30 min").tag(30)
                    Text("45 min").tag(45)
                    Text("1 hour").tag(60)
                    Text("1.5 hours").tag(90)
                    Text("2 hours").tag(120)
                    Text("3 hours").tag(180)
                    Text("All day").tag(1440)
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
    
    var locationAttendeesSection: some View {
        Section(header: Text("Location & Attendees")) {
            TextField("Location (optional)", text: $location)
            
            if !attendees.isEmpty {
                ForEach(attendees, id: \.self) { attendee in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text(attendee)
                        Spacer()
                        Button(action: {
                            attendees.removeAll { $0 == attendee }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Add attendee", text: $newAttendee)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: addAttendee) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
                .disabled(newAttendee.isEmpty)
            }
        }
    }
    
    var recurrenceSection: some View {
        Section(header: Text("Repeat")) {
            Toggle("Recurring Event", isOn: $isRecurring)
            
            if isRecurring {
                Picker("Frequency", selection: $recurrenceFrequency) {
                    ForEach(RecurrenceRule.Frequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                
                if recurrenceFrequency == .weekly {
                    WeekdaySelector(selectedWeekdays: $selectedWeekdays)
                }
                
                if recurrenceFrequency == .monthly {
                    Picker("Repeat On", selection: $monthlyRecurrenceType) {
                        ForEach(MonthlyRecurrenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                if recurrenceFrequency != .daily && recurrenceFrequency != .weekly {
                    Stepper("Every \(recurrenceInterval) \(recurrenceInterval == 1 ? String(recurrenceFrequency.rawValue.dropLast()) : recurrenceFrequency.rawValue)",
                           value: $recurrenceInterval,
                           in: 1...12)
                }
                
                Picker("End Repeat", selection: $recurrenceEndType) {
                    ForEach(RecurrenceEndType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                if recurrenceEndType == .onDate {
                    DatePicker("End Date",
                              selection: $recurrenceEndDate,
                              in: date...,
                              displayedComponents: .date)
                } else if recurrenceEndType == .afterOccurrences {
                    Stepper("After \(recurrenceCount) occurrences",
                           value: $recurrenceCount,
                           in: 1...100)
                }
            }
        }
    }
    
    private func addAttendee() {
        if !newAttendee.isEmpty {
            attendees.append(newAttendee)
            newAttendee = ""
        }
    }
    
    private func saveEvent() {
        var recurrenceRule: RecurrenceRule? = nil
        var recurrenceEndDate: Date? = nil
        var recurrenceCount: Int? = nil
        
        if isRecurring {
            var rule = RecurrenceRule(frequency: recurrenceFrequency)
            rule.interval = recurrenceInterval
            if recurrenceFrequency == .weekly {
                rule.daysOfWeek = Array(selectedWeekdays)
            }
            if recurrenceFrequency == .monthly && monthlyRecurrenceType == .sameDay {
                rule.dayOfMonth = Calendar.current.component(.day, from: date)
            }
            recurrenceRule = rule
            
            switch recurrenceEndType {
            case .never:
                break
            case .onDate:
                recurrenceEndDate = self.recurrenceEndDate
            case .afterOccurrences:
                recurrenceCount = self.recurrenceCount
            }
        }
        
        let event = CalendarEvent(
            title: title,
            description: description,
            date: date,
            duration: duration,
            eventType: eventType,
            category: category,
            location: location.isEmpty ? "" : location,
            attendees: attendees,
            isRecurring: isRecurring,
            recurrenceRule: recurrenceRule,
            recurrenceEndDate: recurrenceEndDate,
            recurrenceCount: recurrenceCount
        )
        
        onSave(event)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Weekday Selector
struct WeekdaySelector: View {
    @Binding var selectedWeekdays: Set<Int>
    let weekdays = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Repeat On")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    // Adjust for calendar week starting on Sunday
                    let dayIndex = index == 0 ? 7 : index
                    
                    Button(action: {
                        if selectedWeekdays.contains(dayIndex) {
                            selectedWeekdays.remove(dayIndex)
                        } else {
                            selectedWeekdays.insert(dayIndex)
                        }
                    }) {
                        Text(weekdays[index])
                            .font(MindLabsTypography.caption())
                            .foregroundColor(selectedWeekdays.contains(dayIndex) ? .white : .mindLabsText)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedWeekdays.contains(dayIndex) ? Color.mindLabsPurple : Color.mindLabsCard)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Recurring Event Detail View
struct RecurringEventDetailView: View {
    let event: CalendarEvent
    let onUpdate: (CalendarEvent) -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Circle()
                                .fill(event.category.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(event.eventType.icon)
                                        .font(.title2)
                                )
                            
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(MindLabsTypography.title3())
                                    .foregroundColor(.mindLabsText)
                                
                                if event.isRecurring {
                                    HStack {
                                        Image(systemName: "repeat")
                                            .font(.caption)
                                        Text(event.recurrenceRule?.frequency.rawValue ?? "Recurring")
                                            .font(MindLabsTypography.caption())
                                    }
                                    .foregroundColor(.mindLabsPurple)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.mindLabsCard)
                        .cornerRadius(15)
                    }
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Date & Time", systemImage: "calendar")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dateFormatter.string(from: event.date))
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                            
                            if event.duration < 1440 {
                                Text("Duration: \(event.duration) minutes")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            } else {
                                Text("All day event")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.mindLabsPurple.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Description
                    if !event.description.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Description", systemImage: "text.alignleft")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            Text(event.description)
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.mindLabsCard)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Location
                    if !event.location.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Location", systemImage: "location")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            Text(event.location)
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.mindLabsCard)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Attendees
                    if !event.attendees.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Label("Attendees", systemImage: "person.2")
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(event.attendees, id: \.self) { attendee in
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(.mindLabsPurple)
                                        Text(attendee)
                                            .font(MindLabsTypography.body())
                                            .foregroundColor(.mindLabsText)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.mindLabsCard)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Actions
                    HStack(spacing: 15) {
                        Button(action: { showingEditView = true }) {
                            Label("Edit", systemImage: "pencil")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.mindLabsPurple)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .alert("Delete Event", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(event.isRecurring ? "This will delete all occurrences of this recurring event." : "Are you sure you want to delete this event?")
            }
        }
    }
}

struct AddRecurringEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddRecurringEventView { _ in }
    }
}