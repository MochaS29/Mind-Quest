import SwiftUI
import UniformTypeIdentifiers

struct DataExportView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedExportType: ExportType = .csv
    @State private var selectedDataSets: Set<DataSet> = []
    @State private var dateRange: DateRange = .lastMonth
    @State private var showingExportSuccess = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    
    enum ExportType: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        case pdf = "PDF Report"
        
        var icon: String {
            switch self {
            case .csv: return "tablecells"
            case .json: return "curlybraces"
            case .pdf: return "doc.text"
            }
        }
        
        var description: String {
            switch self {
            case .csv: return "Spreadsheet compatible format"
            case .json: return "Developer-friendly data format"
            case .pdf: return "Formatted report with charts"
            }
        }
    }
    
    enum DataSet: String, CaseIterable {
        case quests = "Quests & Achievements"
        case timeTracking = "Time Tracking Data"
        case focusSessions = "Focus Sessions"
        case routines = "Daily Routines"
        case streaks = "Streak History"
        case character = "Character Progress"
        
        var icon: String {
            switch self {
            case .quests: return "target"
            case .timeTracking: return "clock"
            case .focusSessions: return "brain"
            case .routines: return "list.bullet.rectangle"
            case .streaks: return "flame"
            case .character: return "person.fill"
            }
        }
    }
    
    enum DateRange: String, CaseIterable {
        case lastWeek = "Last 7 Days"
        case lastMonth = "Last 30 Days"
        case last3Months = "Last 3 Months"
        case allTime = "All Time"
        
        var days: Int? {
            switch self {
            case .lastWeek: return 7
            case .lastMonth: return 30
            case .last3Months: return 90
            case .allTime: return nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Export Type Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Export Format", systemImage: "doc.badge.arrow.up")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        ForEach(ExportType.allCases, id: \.self) { type in
                            ExportTypeCard(
                                type: type,
                                isSelected: selectedExportType == type,
                                onTap: { selectedExportType = type }
                            )
                        }
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    
                    // Data Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Select Data to Export", systemImage: "checkmark.square")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        ForEach(DataSet.allCases, id: \.self) { dataSet in
                            DataSetToggle(
                                dataSet: dataSet,
                                isSelected: selectedDataSets.contains(dataSet),
                                onToggle: {
                                    if selectedDataSets.contains(dataSet) {
                                        selectedDataSets.remove(dataSet)
                                    } else {
                                        selectedDataSets.insert(dataSet)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    
                    // Date Range Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Label("Date Range", systemImage: "calendar")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Picker("Date Range", selection: $dateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color.mindLabsCard)
                    .cornerRadius(15)
                    
                    // Export Button
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "arrow.up.doc.fill")
                            Text("Export Data")
                        }
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient.mindLabsPrimary
                                .opacity(selectedDataSets.isEmpty ? 0.5 : 1.0)
                        )
                        .cornerRadius(15)
                    }
                    .disabled(selectedDataSets.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .alert("Export Complete!", isPresented: $showingExportSuccess) {
                Button("Share") {
                    showingShareSheet = true
                }
                Button("Done", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Your data has been exported successfully.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ExportShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportData() {
        switch selectedExportType {
        case .csv:
            exportToCSV()
        case .json:
            exportToJSON()
        case .pdf:
            exportToPDF()
        }
    }
    
    private func exportToCSV() {
        var csvContent = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        // Export Quests
        if selectedDataSets.contains(.quests) {
            csvContent += "QUESTS DATA\n"
            csvContent += "Title,Category,Difficulty,Status,Completed Date,XP,Gold,Time Spent (min)\n"
            
            let quests = filterQuestsByDateRange()
            for quest in quests {
                let completedDate = quest.completedAt.map { dateFormatter.string(from: $0) } ?? "Not completed"
                csvContent += "\"\(quest.title)\",\(quest.category.rawValue),\(quest.difficulty.rawValue),\(quest.isCompleted ? "Completed" : "Active"),\(completedDate),\(quest.xpReward),\(quest.goldReward),\(quest.actualTimeSpent)\n"
            }
            csvContent += "\n"
        }
        
        // Export Focus Sessions
        if selectedDataSets.contains(.focusSessions) {
            csvContent += "FOCUS SESSIONS DATA\n"
            csvContent += "Date,Duration (min),Type\n"
            
            // Get focus session data from timer history
            let calendar = Calendar.current
            let endDate = Date()
            if let days = dateRange.days {
                _ = calendar.date(byAdding: .day, value: -days, to: endDate)!
                // Add focus session export logic here
            }
            csvContent += "\n"
        }
        
        // Export Character Progress
        if selectedDataSets.contains(.character) {
            csvContent += "CHARACTER PROGRESS\n"
            csvContent += "Metric,Value\n"
            csvContent += "Name,\(gameManager.character.name)\n"
            csvContent += "Level,\(gameManager.character.level)\n"
            csvContent += "Total XP,\(gameManager.character.xp)\n"
            csvContent += "Gold,\(gameManager.character.gold)\n"
            csvContent += "Current Streak,\(gameManager.character.streak)\n"
            csvContent += "Total Quests Completed,\(gameManager.character.totalQuestsCompleted)\n"
            csvContent += "Total Focus Minutes,\(gameManager.character.totalFocusMinutes)\n"
            csvContent += "\n"
        }
        
        // Save to file
        saveToFile(content: csvContent, filename: "mindlabs_export_\(Date().timeIntervalSince1970).csv")
    }
    
    private func exportToJSON() {
        var exportData: [String: Any] = [:]
        
        exportData["exportDate"] = ISO8601DateFormatter().string(from: Date())
        exportData["dateRange"] = dateRange.rawValue
        
        if selectedDataSets.contains(.quests) {
            let quests = filterQuestsByDateRange()
            exportData["quests"] = quests.map { quest in
                [
                    "id": quest.id.uuidString,
                    "title": quest.title,
                    "category": quest.category.rawValue,
                    "difficulty": quest.difficulty.rawValue,
                    "isCompleted": quest.isCompleted,
                    "completedAt": quest.completedAt.map { ISO8601DateFormatter().string(from: $0) } as Any,
                    "xpReward": quest.xpReward,
                    "goldReward": quest.goldReward,
                    "actualTimeSpent": quest.actualTimeSpent
                ]
            }
        }
        
        if selectedDataSets.contains(.character) {
            exportData["character"] = [
                "name": gameManager.character.name,
                "level": gameManager.character.level,
                "xp": gameManager.character.xp,
                "gold": gameManager.character.gold,
                "streak": gameManager.character.streak,
                "totalQuestsCompleted": gameManager.character.totalQuestsCompleted,
                "totalFocusMinutes": gameManager.character.totalFocusMinutes,
                "stats": gameManager.character.stats
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            saveToFile(content: jsonString, filename: "mindlabs_export_\(Date().timeIntervalSince1970).json")
        }
    }
    
    private func exportToPDF() {
        // For now, create a simple text-based PDF
        // In a real implementation, you'd use PDFKit to create a formatted report
        var pdfContent = """
        Mind Labs Quest Progress Report
        Generated: \(Date())
        
        """
        
        if selectedDataSets.contains(.character) {
            pdfContent += """
            CHARACTER OVERVIEW
            ==================
            Name: \(gameManager.character.name)
            Level: \(gameManager.character.level)
            Total XP: \(gameManager.character.xp)
            Gold: \(gameManager.character.gold)
            Current Streak: \(gameManager.character.streak) days
            
            """
        }
        
        if selectedDataSets.contains(.quests) {
            let completedQuests = filterQuestsByDateRange().filter { $0.isCompleted }
            pdfContent += """
            COMPLETED QUESTS (\(dateRange.rawValue))
            ==================
            Total: \(completedQuests.count)
            
            """
            
            for quest in completedQuests.prefix(10) {
                pdfContent += "• \(quest.title) - \(quest.category.rawValue)\n"
            }
        }
        
        // For now, save as text file
        saveToFile(content: pdfContent, filename: "mindlabs_report_\(Date().timeIntervalSince1970).txt")
    }
    
    private func filterQuestsByDateRange() -> [Quest] {
        guard let days = dateRange.days else {
            return gameManager.quests
        }
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        
        return gameManager.quests.filter { quest in
            if let completedAt = quest.completedAt {
                return completedAt >= startDate
            }
            return quest.createdDate >= startDate
        }
    }
    
    private func saveToFile(content: String, filename: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            exportedFileURL = fileURL
            showingExportSuccess = true
        } catch {
            print("Failed to save file: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct ExportTypeCard: View {
    let type: DataExportView.ExportType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .mindLabsPurple)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(isSelected ? .white : .mindLabsText)
                    
                    Text(type.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .mindLabsTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.mindLabsPurple : Color.mindLabsPurple.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DataSetToggle: View {
    let dataSet: DataExportView.DataSet
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: dataSet.icon)
                    .font(.title3)
                    .foregroundColor(.mindLabsPurple)
                    .frame(width: 30)
                
                Text(dataSet.rawValue)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsText)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsTextSecondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Export Share Sheet

struct ExportShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DataExportView_Previews: PreviewProvider {
    static var previews: some View {
        DataExportView()
            .environmentObject(GameManager())
    }
}