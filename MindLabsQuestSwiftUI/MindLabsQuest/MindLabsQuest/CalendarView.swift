import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedViewType: CalendarViewType = .visual
    @State private var showingClassicView = false
    
    enum CalendarViewType: String, CaseIterable {
        case visual = "Visual"
        case classic = "Classic"
    }
    
    var body: some View {
        NavigationView {
            VisualCalendarView()
                .environmentObject(gameManager)
                .navigationBarItems(
                    trailing: Button(action: {
                        showingClassicView = true
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Classic")
                        }
                        .foregroundColor(.mindLabsPurple)
                    }
                )
                .sheet(isPresented: $showingClassicView) {
                    ClassicCalendarView()
                        .environmentObject(gameManager)
                }
        }
    }
}

// Move the original CalendarView content to ClassicCalendarView
struct ClassicCalendarView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var showAddEventSheet = false
    @State private var calendarEvents: [CalendarEvent] = []
    @State private var currentMonth = Date()
    @State private var selectedEvent: CalendarEvent?
    @State private var showEventDetail = false
    @State private var showCalendarSyncSheet = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.mindLabsPurple)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: currentMonth))
                        .font(MindLabsTypography.title2())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.mindLabsPurple)
                            .font(.title2)
                    }
                }
                .padding()
                
                // Calendar Grid
                CalendarGridView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    events: calendarEvents
                )
                
                // Events for selected date
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Events for \(selectedDate, formatter: dayFormatter)")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddEventSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.mindLabsPurple)
                                .font(.title3)
                        }
                    }
                    .padding(.horizontal)
                    
                    if eventsForSelectedDate.isEmpty {
                        VStack(spacing: 20) {
                            Text("📅")
                                .font(.system(size: 50))
                            Text("No events scheduled")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Button(action: {
                                showAddEventSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Event")
                                }
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(LinearGradient.mindLabsPrimary)
                                .cornerRadius(25)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(eventsForSelectedDate) { event in
                                    EventCard(event: event, onTap: {
                                        selectedEvent = event
                                        showEventDetail = true
                                    })
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .background(Color.mindLabsCard)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .mindLabsCardShadow()
            }
            .navigationTitle("Classic Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Visual")
                    }
                    .foregroundColor(.mindLabsPurple)
                },
                trailing: Button(action: {
                    showCalendarSyncSheet = true
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.mindLabsPurple)
                }
            )
            .sheet(isPresented: $showAddEventSheet) {
                AddEventView(selectedDate: selectedDate, onSave: { event in
                    calendarEvents.append(event)
                    saveEvents()
                })
            }
            .sheet(isPresented: $showEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(event: event, onConvert: { quest in
                        gameManager.addQuest(quest)
                        if let index = calendarEvents.firstIndex(where: { $0.id == event.id }) {
                            calendarEvents[index].convertedToQuest = true
                            calendarEvents[index].relatedQuestId = quest.id
                            saveEvents()
                        }
                    }, onDelete: {
                        calendarEvents.removeAll { $0.id == event.id }
                        saveEvents()
                        showEventDetail = false
                    })
                }
            }
            .sheet(isPresented: $showCalendarSyncSheet) {
                CalendarSyncView()
            }
        }
        .onAppear {
            loadEvents()
            checkForSyncedEvents()
        }
    }
    
    // MARK: - Helper Functions
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        calendarEvents.filter { event in
            calendar.isDate(event.date, inSameDayAs: selectedDate)
        }
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(calendarEvents) {
            UserDefaults.standard.set(encoded, forKey: "calendarEvents")
        }
    }
    
    private func loadEvents() {
        if let data = UserDefaults.standard.data(forKey: "calendarEvents"),
           let decoded = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            calendarEvents = decoded
        }
    }
    
    private func checkForSyncedEvents() {
        // Check if calendar sync is enabled and perform auto-sync if needed
        let calendarManager = CalendarManager.shared
        if calendarManager.syncSettings.isEnabled &&
           calendarManager.authorizationStatus == .authorized {
            // Auto-sync in background
            calendarManager.syncEventsFromCalendar { newEvents in
                DispatchQueue.main.async {
                    // Merge new events with existing ones
                    for event in newEvents {
                        if !self.calendarEvents.contains(where: { $0.calendarIdentifier == event.calendarIdentifier }) {
                            self.calendarEvents.append(event)
                        }
                    }
                    self.saveEvents()
                }
            }
        }
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    
    private let calendar = Calendar.current
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            eventCount: countEvents(for: date),
                            onTap: {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDate = date
                                }
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 45)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func countEvents(for date: Date) -> Int {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let eventCount: Int
    let onTap: () -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
                    )
                
                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: date))
                        .font(MindLabsTypography.body())
                        .foregroundColor(textColor)
                    
                    if eventCount > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<min(eventCount, 3), id: \.self) { _ in
                                Circle()
                                    .fill(Color.mindLabsPurple)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
            }
            .frame(height: 45)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.mindLabsPurple.opacity(0.2)
        } else if isToday {
            return Color.mindLabsPurple.opacity(0.1)
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.mindLabsPurple
        } else if isToday {
            return Color.mindLabsPurple.opacity(0.5)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return Color.mindLabsTextLight
        } else if isSelected || isToday {
            return Color.mindLabsPurple
        } else {
            return Color.mindLabsText
        }
    }
}

// MARK: - Event Card
struct EventCard: View {
    let event: CalendarEvent
    let onTap: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(event.eventType.icon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(event.category.color.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                        .lineLimit(1)
                    
                    HStack {
                        Text(timeFormatter.string(from: event.date))
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text("•")
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        Text(event.courseOrSubject.isEmpty ? event.category.rawValue : event.courseOrSubject)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Circle()
                        .fill(event.priority.color)
                        .frame(width: 8, height: 8)
                    
                    if event.convertedToQuest {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.mindLabsSuccess)
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(Color.mindLabsBorder.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.mindLabsBorder.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(GameManager())
    }
}