import SwiftUI

struct VisualCalendarView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var calendarManager = CalendarManager.shared
    
    @State private var selectedDate = Date()
    @State private var selectedView: CalendarViewType = .month
    @State private var showingAddEvent = false
    @State private var selectedEvent: CalendarEvent?
    @State private var calendarEvents: [CalendarEvent] = []
    @State private var showingEventDetail = false
    
    var showClassicButton = false
    
    enum CalendarViewType: String, CaseIterable {
        case month = "Month"
        case week = "Week"
        case day = "Day"
        
        var icon: String {
            switch self {
            case .month: return "calendar"
            case .week: return "calendar.day.timeline.left"
            case .day: return "calendar.circle"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // View Type Selector
            Picker("View Type", selection: $selectedView) {
                ForEach(CalendarViewType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.mindLabsCard)
            
            // Calendar Content
            Group {
                switch selectedView {
                    case .month:
                        MonthCalendarView(
                            selectedDate: $selectedDate,
                            events: calendarEvents,
                            onDateSelected: { date in
                                selectedDate = date
                            },
                            onEventSelected: { event in
                                selectedEvent = event
                                showingEventDetail = true
                            }
                        )
                    case .week:
                        WeekCalendarView(
                            selectedDate: $selectedDate,
                            events: calendarEvents,
                            onEventSelected: { event in
                                selectedEvent = event
                                showingEventDetail = true
                            }
                        )
                    case .day:
                        DayCalendarView(
                            selectedDate: selectedDate,
                            events: calendarEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) },
                            onEventSelected: { event in
                                selectedEvent = event
                                showingEventDetail = true
                            }
                        )
                    }
                }
                
            Spacer()
        }
        .navigationTitle("Calendar Planner")
        .navigationBarTitleDisplayMode(.inline)
        .mindLabsBackground()
        .navigationBarItems(
                leading: showClassicButton ? Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("Classic")
                    }
                    .foregroundColor(.mindLabsPurple)
                } : nil,
                trailing: Button(action: { showingAddEvent = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            )
            .sheet(isPresented: $showingAddEvent) {
                AddRecurringEventView(onSave: { event in
                    addEvent(event)
                })
            }
            .sheet(item: $selectedEvent) { event in
                RecurringEventDetailView(event: event, onUpdate: { updatedEvent in
                    updateEvent(updatedEvent)
                }, onDelete: {
                    deleteEvent(event)
                })
            }
        .onAppear {
            loadEvents()
        }
    }
    
    private func loadEvents() {
        // Load saved events
        if let data = UserDefaults.standard.data(forKey: "calendarEvents"),
           let events = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            
            // Expand recurring events
            var allEvents: [CalendarEvent] = []
            let calendar = Calendar.current
            let endDate = calendar.date(byAdding: .month, value: 3, to: Date()) ?? Date()
            
            for event in events {
                if event.isRecurring, let rule = event.recurrenceRule {
                    allEvents.append(contentsOf: generateRecurringInstances(for: event, rule: rule, until: endDate))
                } else {
                    allEvents.append(event)
                }
            }
            
            calendarEvents = allEvents
        }
    }
    
    private func generateRecurringInstances(for event: CalendarEvent, rule: RecurrenceRule, until endDate: Date) -> [CalendarEvent] {
        var instances: [CalendarEvent] = []
        var currentDate = event.date
        let calendar = Calendar.current
        var occurrenceCount = 0
        
        while currentDate <= endDate {
            // Check if we've reached the recurrence limit
            if let maxCount = event.recurrenceCount, occurrenceCount >= maxCount {
                break
            }
            
            if let recEndDate = event.recurrenceEndDate, currentDate > recEndDate {
                break
            }
            
            // Check if this date is an exception
            let isException = event.exceptionDates.contains { calendar.isDate($0, inSameDayAs: currentDate) }
            
            if !isException {
                var instance = event
                instance.id = UUID()
                instance.date = currentDate
                instance.originalEventId = event.id
                instances.append(instance)
                occurrenceCount += 1
            }
            
            // Calculate next occurrence
            switch rule.frequency {
            case .daily:
                currentDate = calendar.date(byAdding: .day, value: rule.interval, to: currentDate) ?? currentDate
            case .weekly:
                currentDate = calendar.date(byAdding: .weekOfYear, value: rule.interval, to: currentDate) ?? currentDate
            case .biweekly:
                currentDate = calendar.date(byAdding: .weekOfYear, value: rule.interval * 2, to: currentDate) ?? currentDate
            case .monthly:
                currentDate = calendar.date(byAdding: .month, value: rule.interval, to: currentDate) ?? currentDate
            case .yearly:
                currentDate = calendar.date(byAdding: .year, value: rule.interval, to: currentDate) ?? currentDate
            }
        }
        
        return instances
    }
    
    private func addEvent(_ event: CalendarEvent) {
        if var events = UserDefaults.standard.data(forKey: "calendarEvents")
            .flatMap({ try? JSONDecoder().decode([CalendarEvent].self, from: $0) }) {
            events.append(event)
            saveEvents(events)
        } else {
            saveEvents([event])
        }
        loadEvents()
    }
    
    private func updateEvent(_ event: CalendarEvent) {
        if var events = UserDefaults.standard.data(forKey: "calendarEvents")
            .flatMap({ try? JSONDecoder().decode([CalendarEvent].self, from: $0) }) {
            if let index = events.firstIndex(where: { $0.id == event.id }) {
                events[index] = event
                saveEvents(events)
                loadEvents()
            }
        }
    }
    
    private func deleteEvent(_ event: CalendarEvent) {
        if var events = UserDefaults.standard.data(forKey: "calendarEvents")
            .flatMap({ try? JSONDecoder().decode([CalendarEvent].self, from: $0) }) {
            events.removeAll { $0.id == event.id }
            saveEvents(events)
            loadEvents()
        }
    }
    
    private func saveEvents(_ events: [CalendarEvent]) {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: "calendarEvents")
        }
    }
}

// MARK: - Month Calendar View
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    let onDateSelected: (Date) -> Void
    let onEventSelected: (CalendarEvent) -> Void
    
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Month Header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.mindLabsPurple)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.mindLabsPurple)
                }
            }
            .padding()
            
            // Weekday Headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(monthDays(), id: \.self) { date in
                    VisualDayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        events: eventsForDate(date),
                        onTap: {
                            selectedDate = date
                            onDateSelected(date)
                        },
                        onEventTap: onEventSelected
                    )
                }
            }
            .padding()
        }
    }
    
    private func monthDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date] = []
        var date = firstWeek.start
        
        while date < monthInterval.end || !calendar.isDate(date, equalTo: monthInterval.end, toGranularity: .weekOfMonth) {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

// MARK: - Day Cell
struct VisualDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let events: [CalendarEvent]
    let onTap: () -> Void
    let onEventTap: (CalendarEvent) -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayFormatter.string(from: date))
                .font(MindLabsTypography.subheadline())
                .foregroundColor(textColor)
                .frame(width: 30, height: 30)
                .background(backgroundColor)
                .clipShape(Circle())
            
            // Event Indicators
            HStack(spacing: 2) {
                ForEach(events.prefix(3)) { event in
                    Circle()
                        .fill(event.category.color)
                        .frame(width: 6, height: 6)
                }
                if events.count > 3 {
                    Text("+\(events.count - 3)")
                        .font(.system(size: 8))
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .frame(height: 10)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            onTap()
        }
    }
    
    var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .mindLabsPurple
        } else if isCurrentMonth {
            return .mindLabsText
        } else {
            return .mindLabsTextSecondary
        }
    }
    
    var backgroundColor: Color {
        if isSelected {
            return .mindLabsPurple
        } else if isToday {
            return .mindLabsPurple.opacity(0.2)
        } else {
            return .clear
        }
    }
}

// MARK: - Week Calendar View
struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    let onEventSelected: (CalendarEvent) -> Void
    
    private let calendar = Calendar.current
    private let hourHeight: CGFloat = 60
    
    var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var date = weekInterval.start
        
        for _ in 0..<7 {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Week Header
                WeekHeaderView(weekDays: weekDays, selectedDate: $selectedDate)
                
                // Time Grid
                ZStack(alignment: .topLeading) {
                    // Hour Lines
                    VStack(spacing: 0) {
                        ForEach(0..<24) { hour in
                            HStack {
                                Text("\(hour):00")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(width: 50, alignment: .trailing)
                                
                                Rectangle()
                                    .fill(Color.mindLabsTextSecondary.opacity(0.2))
                                    .frame(height: 1)
                            }
                            .frame(height: hourHeight)
                        }
                    }
                    
                    // Events
                    HStack(spacing: 1) {
                        Spacer()
                            .frame(width: 55)
                        
                        ForEach(weekDays, id: \.self) { day in
                            DayColumnView(
                                date: day,
                                events: eventsForDate(day),
                                hourHeight: hourHeight,
                                onEventSelected: onEventSelected
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEvent] {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

// MARK: - Week Header View
struct WeekHeaderView: View {
    let weekDays: [Date]
    @Binding var selectedDate: Date
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 1) {
            Spacer()
                .frame(width: 55)
            
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: day))
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Text(dateFormatter.string(from: day))
                        .font(MindLabsTypography.headline())
                        .foregroundColor(Calendar.current.isDate(day, inSameDayAs: selectedDate) ? .white : .mindLabsText)
                        .frame(width: 35, height: 35)
                        .background(
                            Calendar.current.isDate(day, inSameDayAs: selectedDate) ?
                            Color.mindLabsPurple : Color.clear
                        )
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = day
                }
            }
        }
        .padding(.vertical)
        .background(Color.mindLabsCard)
    }
}

// MARK: - Day Column View
struct DayColumnView: View {
    let date: Date
    let events: [CalendarEvent]
    let hourHeight: CGFloat
    let onEventSelected: (CalendarEvent) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(events) { event in
                EventBlockView(
                    event: event,
                    hourHeight: hourHeight,
                    columnWidth: geometry.size.width,
                    onTap: { onEventSelected(event) }
                )
            }
        }
    }
}

// MARK: - Event Block View
struct EventBlockView: View {
    let event: CalendarEvent
    let hourHeight: CGFloat
    let columnWidth: CGFloat
    let onTap: () -> Void
    
    private var offset: CGFloat {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: event.date)
        let minute = calendar.component(.minute, from: event.date)
        return CGFloat(hour) * hourHeight + CGFloat(minute) / 60 * hourHeight
    }
    
    private var height: CGFloat {
        CGFloat(event.duration) / 60 * hourHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(MindLabsTypography.caption())
                .foregroundColor(.white)
                .lineLimit(1)
            
            if event.isRecurring {
                Image(systemName: "repeat")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(4)
        .frame(width: columnWidth - 4, height: max(height - 4, 20), alignment: .topLeading)
        .background(event.category.color.opacity(0.9))
        .cornerRadius(6)
        .offset(y: offset)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Day Calendar View
struct DayCalendarView: View {
    let selectedDate: Date
    let events: [CalendarEvent]
    let onEventSelected: (CalendarEvent) -> Void
    
    private let hourHeight: CGFloat = 80
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    var sortedEvents: [CalendarEvent] {
        events.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date Header
                Text(dateFormatter.string(from: selectedDate))
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                    .padding(.horizontal)
                
                if sortedEvents.isEmpty {
                    EmptyDayView()
                } else {
                    // Events List
                    ForEach(sortedEvents) { event in
                        DayEventRow(event: event)
                            .onTapGesture {
                                onEventSelected(event)
                            }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Day Event Row
struct DayEventRow: View {
    let event: CalendarEvent
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 15) {
            // Time
            VStack(alignment: .trailing, spacing: 2) {
                Text(timeFormatter.string(from: event.date))
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsText)
                
                Text("\(event.duration) min")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .frame(width: 80)
            
            // Event Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Circle()
                        .fill(event.category.color)
                        .frame(width: 12, height: 12)
                    
                    Text(event.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    if event.isRecurring {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 10) {
                    if !event.location.isEmpty {
                        Label(event.location, systemImage: "location")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Label(event.eventType.rawValue, systemImage: "tag")
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.mindLabsCard)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Empty Day View
struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.mindLabsTextSecondary)
            
            Text("No events scheduled")
                .font(MindLabsTypography.body())
                .foregroundColor(.mindLabsTextSecondary)
            
            Text("Tap + to add an event")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct VisualCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        VisualCalendarView()
            .environmentObject(GameManager())
    }
}