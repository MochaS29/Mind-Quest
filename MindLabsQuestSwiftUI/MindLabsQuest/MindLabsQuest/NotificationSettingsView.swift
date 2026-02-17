import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Notification Settings
    @State private var enableQuestReminders = true
    @State private var enableTimerNotifications = true
    @State private var enableDailyReminders = true
    @State private var enableStreakReminders = true
    @State private var enableMedicationReminders = false
    @State private var enableHyperfocusProtection = false
    
    // Daily Reminder Time
    @State private var dailyReminderTime = Date()
    
    // Hyperfocus Settings
    @State private var hyperfocusInterval = 90
    
    // Medication Reminders
    @State private var medications: [MedicationReminder] = []
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationView {
            Form {
                // General Notifications
                Section(header: Text("General Notifications")) {
                    Toggle("Quest Reminders", isOn: $enableQuestReminders)
                        .tint(.mindLabsPurple)
                    
                    Toggle("Timer Completion", isOn: $enableTimerNotifications)
                        .tint(.mindLabsPurple)
                    
                    Toggle("Streak Reminders", isOn: $enableStreakReminders)
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Daily Quest Reminder
                Section(header: Text("Daily Quest Reminder")) {
                    Toggle("Enable Daily Reminder", isOn: $enableDailyReminders)
                        .tint(.mindLabsPurple)
                    
                    if enableDailyReminders {
                        DatePicker("Reminder Time", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: dailyReminderTime) { _ in
                                scheduleDailyReminder()
                            }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                // ADHD-Specific Features
                Section(header: Text("ADHD Support Features")) {
                    // Hyperfocus Protection
                    Toggle("Hyperfocus Protection", isOn: $enableHyperfocusProtection)
                        .tint(.mindLabsPurple)
                        .onChange(of: enableHyperfocusProtection) { enabled in
                            if enabled {
                                notificationManager.scheduleHyperfocusProtection(intervalMinutes: hyperfocusInterval)
                            } else {
                                notificationManager.cancelHyperfocusProtection()
                            }
                        }
                    
                    if enableHyperfocusProtection {
                        HStack {
                            Text("Check-in Interval")
                            Spacer()
                            Picker("", selection: $hyperfocusInterval) {
                                Text("60 min").tag(60)
                                Text("90 min").tag(90)
                                Text("120 min").tag(120)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: hyperfocusInterval) { newInterval in
                                notificationManager.cancelHyperfocusProtection()
                                notificationManager.scheduleHyperfocusProtection(intervalMinutes: newInterval)
                            }
                        }
                    }
                    
                    // Medication Reminders
                    Toggle("Medication Reminders", isOn: $enableMedicationReminders)
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Medication List
                if enableMedicationReminders {
                    Section(header: HStack {
                        Text("Medications")
                        Spacer()
                        Button(action: { showingAddMedication = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }) {
                        if medications.isEmpty {
                            Text("No medications added")
                                .foregroundColor(.mindLabsTextSecondary)
                                .font(MindLabsTypography.caption())
                        } else {
                            ForEach(medications) { medication in
                                MedicationReminderRow(medication: medication)
                            }
                            .onDelete(perform: deleteMedication)
                        }
                    }
                    .listRowBackground(Color.mindLabsCard)
                }
                
                // Notification Preferences
                Section(header: Text("Notification Preferences")) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text("Sound")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                            .tint(.mindLabsPurple)
                    }
                    
                    HStack {
                        Image(systemName: "app.badge.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text("Badges")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                            .tint(.mindLabsPurple)
                    }
                    
                    HStack {
                        Image(systemName: "banner.fill")
                            .foregroundColor(.mindLabsPurple)
                        Text("Banners")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                            .labelsHidden()
                            .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                // Test Notifications
                Section {
                    Button(action: sendTestNotification) {
                        HStack {
                            Image(systemName: "bell.badge")
                            Text("Send Test Notification")
                        }
                        .foregroundColor(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView(medications: $medications)
            }
        }
        .mindLabsBackground()
        .onAppear {
            loadSettings()
            notificationManager.setupNotificationCategories()
        }
    }
    
    private func scheduleDailyReminder() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: dailyReminderTime)
        notificationManager.scheduleDailyQuestReminder(at: components.hour ?? 9, minute: components.minute ?? 0)
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification 🧪"
        content.body = "Your notifications are working correctly!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func deleteMedication(at offsets: IndexSet) {
        for index in offsets {
            let medication = medications[index]
            notificationManager.cancelMedicationReminder(id: medication.id)
        }
        medications.remove(atOffsets: offsets)
        saveSettings()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "notificationSettings"),
           let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) {
            enableQuestReminders = settings.enableQuestReminders
            enableTimerNotifications = settings.enableTimerNotifications
            enableDailyReminders = settings.enableDailyReminders
            enableStreakReminders = settings.enableStreakReminders
            enableMedicationReminders = settings.enableMedicationReminders
            enableHyperfocusProtection = settings.enableHyperfocusProtection
            dailyReminderTime = settings.dailyReminderTime
            hyperfocusInterval = settings.hyperfocusInterval
            medications = settings.medications
        }
    }
    
    private func saveSettings() {
        let settings = NotificationSettings(
            enableQuestReminders: enableQuestReminders,
            enableTimerNotifications: enableTimerNotifications,
            enableDailyReminders: enableDailyReminders,
            enableStreakReminders: enableStreakReminders,
            enableMedicationReminders: enableMedicationReminders,
            enableHyperfocusProtection: enableHyperfocusProtection,
            dailyReminderTime: dailyReminderTime,
            hyperfocusInterval: hyperfocusInterval,
            medications: medications
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "notificationSettings")
        }
    }
}

// MARK: - Supporting Views
struct MedicationReminderRow: View {
    let medication: MedicationReminder
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundColor(.mindLabsPurple)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(.mindLabsText)
                
                HStack {
                    Text(medication.dosage ?? "")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Text("•")
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Text(formatTime(medication.time))
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    private func formatTime(_ components: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        if let date = Calendar.current.date(from: dateComponents) {
            return formatter.string(from: date)
        }
        return ""
    }
}

struct AddMedicationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var medications: [MedicationReminder]
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var time = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (optional)", text: $dosage)
                    DatePicker("Reminder Time", selection: $time, displayedComponents: .hourAndMinute)
                    TextField("Notes (optional)", text: $notes)
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                trailing: Button("Save") {
                    saveMedication()
                }
                .foregroundColor(.mindLabsPurple)
                .disabled(name.isEmpty)
            )
        }
        .mindLabsBackground()
    }
    
    private func saveMedication() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let medication = MedicationReminder(
            id: UUID(),
            name: name,
            dosage: dosage.isEmpty ? nil : dosage,
            time: components,
            notes: notes.isEmpty ? nil : notes
        )
        
        medications.append(medication)
        
        // Schedule the notification
        NotificationManager.shared.scheduleMedicationReminder(
            name: medication.name,
            time: medication.time,
            dosage: medication.dosage,
            notes: medication.notes,
            id: medication.id
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Models
struct NotificationSettings: Codable {
    var enableQuestReminders: Bool
    var enableTimerNotifications: Bool
    var enableDailyReminders: Bool
    var enableStreakReminders: Bool
    var enableMedicationReminders: Bool
    var enableHyperfocusProtection: Bool
    var dailyReminderTime: Date
    var hyperfocusInterval: Int
    var medications: [MedicationReminder]
}

struct MedicationReminder: Identifiable, Codable {
    let id: UUID
    let name: String
    let dosage: String?
    let time: DateComponents
    let notes: String?
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}