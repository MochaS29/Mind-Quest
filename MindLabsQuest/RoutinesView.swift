import SwiftUI

struct RoutinesView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showNewRoutineSheet = false
    @State private var selectedRoutine: Routine?
    @State private var showDeleteAlert = false
    @State private var routineToDelete: Routine?
    
    var activeRoutines: [Routine] {
        gameManager.routines.filter { $0.isActive }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if activeRoutines.isEmpty {
                    // Empty State
                    Spacer()
                    VStack(spacing: 20) {
                        Text("🗓️")
                            .font(.system(size: 80))
                        Text("No routines yet")
                            .font(MindLabsTypography.title2())
                            .foregroundColor(.mindLabsText)
                        Text("Create daily routines to build healthy habits")
                            .font(MindLabsTypography.body())
                            .foregroundColor(.mindLabsTextSecondary)
                            .multilineTextAlignment(.center)
                        Button("Create First Routine") {
                            showNewRoutineSheet = true
                        }
                        .buttonStyle(MindLabsPrimaryButtonStyle())
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(activeRoutines) { routine in
                                RoutineCard(routine: routine) {
                                    selectedRoutine = routine
                                }
                                .contextMenu {
                                    Button("Edit") {
                                        selectedRoutine = routine
                                    }
                                    Button("Delete", role: .destructive) {
                                        routineToDelete = routine
                                        showDeleteAlert = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Daily Routines")
            .mindLabsBackground()
            .navigationBarItems(trailing:
                Button(action: {
                    showNewRoutineSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.mindLabsPurple)
                }
            )
        }
        .sheet(isPresented: $showNewRoutineSheet) {
            NewRoutineView()
        }
        .sheet(item: $selectedRoutine) { routine in
            RoutineDetailView(routine: routine)
        }
        .alert("Delete Routine?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let routine = routineToDelete {
                    gameManager.deleteRoutine(routine)
                }
            }
        } message: {
            Text("This will permanently delete the routine and its progress.")
        }
    }
}

struct RoutineCard: View {
    let routine: Routine
    let onTap: () -> Void
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        Button(action: onTap) {
            MindLabsCard {
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Text(routine.icon)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsText)
                            
                            HStack {
                                Label("\(routine.totalEstimatedTime) min", systemImage: "clock")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                
                                if routine.completionStreak > 0 {
                                    Label("\(routine.completionStreak) day streak", systemImage: "flame.fill")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if routine.isCompletedToday {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.mindLabsSuccess)
                        } else {
                            VStack {
                                Text("\(routine.completedStepsToday)")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsPurple)
                                Text("of \(routine.steps.count)")
                                    .font(MindLabsTypography.caption2())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                    }
                    
                    // Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.mindLabsBorder.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(
                                    routine.isCompletedToday
                                        ? LinearGradient(colors: [Color.mindLabsSuccess], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient.mindLabsPrimary
                                )
                                .frame(width: geometry.size.width * routine.progressToday, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    // Next Steps Preview
                    if !routine.isCompletedToday && routine.steps.count > 0 {
                        HStack {
                            Text("Next:")
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            if let nextStep = routine.steps.first(where: { !$0.isCompletedToday }) {
                                Text("\(nextStep.icon) \(nextStep.title)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsText)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RoutineDetailView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State var routine: Routine
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Text(routine.icon)
                            .font(.system(size: 60))
                        
                        VStack(alignment: .leading) {
                            Text(routine.name)
                                .font(MindLabsTypography.title2())
                                .foregroundColor(.mindLabsText)
                            
                            HStack {
                                Label("\(routine.totalEstimatedTime) min total", systemImage: "clock")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                                
                                if routine.completionStreak > 0 {
                                    Label("\(routine.completionStreak) day streak", systemImage: "flame.fill")
                                        .font(MindLabsTypography.caption())
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Today's Progress")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            Spacer()
                            Text("\(routine.completedStepsToday)/\(routine.steps.count) steps")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsText)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.mindLabsBorder.opacity(0.3))
                                    .frame(height: 10)
                                    .cornerRadius(5)
                                
                                Rectangle()
                                    .fill(
                                        routine.isCompletedToday
                                            ? LinearGradient(colors: [Color.mindLabsSuccess], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient.mindLabsPrimary
                                    )
                                    .frame(width: geometry.size.width * routine.progressToday, height: 10)
                                    .cornerRadius(5)
                            }
                        }
                        .frame(height: 10)
                    }
                }
                .padding()
                .background(Color.mindLabsCard)
                
                // Steps List
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routine.steps.indices, id: \.self) { index in
                            RoutineStepRow(
                                step: routine.steps[index],
                                index: index + 1
                            ) {
                                gameManager.toggleRoutineStep(routine.steps[index].id, in: routine.id)
                                // Refresh local state
                                if let updatedRoutine = gameManager.routines.first(where: { $0.id == routine.id }) {
                                    routine = updatedRoutine
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Completion Message
                if routine.isCompletedToday {
                    VStack(spacing: 10) {
                        Text("🎉 Routine Complete!")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsSuccess)
                        Text("Great job maintaining your routine!")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.mindLabsSuccess.opacity(0.1))
                }
            }
            .navigationTitle("Routine Progress")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                
                trailing: Button("Edit") {
                    showEditSheet = true
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditRoutineView(routine: routine)
        }
    }
}

struct RoutineStepRow: View {
    let step: RoutineStep
    let index: Int
    let onToggle: () -> Void
    
    var body: some View {
        MindLabsCard(padding: 12) {
            HStack(spacing: 15) {
                // Step Number
                Text("\(index)")
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                    .frame(width: 20)
                
                // Icon
                Text(step.icon)
                    .font(.system(size: 30))
                
                // Title and Time
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(step.isCompletedToday ? .mindLabsTextSecondary : .mindLabsText)
                        .strikethrough(step.isCompletedToday)
                    
                    HStack {
                        Label("\(step.estimatedTime) min", systemImage: "clock")
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        if step.isOptional {
                            Text("Optional")
                                .font(MindLabsTypography.caption2())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.mindLabsWarning.opacity(0.2))
                                .foregroundColor(.mindLabsWarning)
                                .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
                
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: step.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(step.isCompletedToday ? .mindLabsSuccess : .mindLabsTextLight)
                }
            }
        }
        .opacity(step.isCompletedToday ? 0.8 : 1.0)
    }
}

struct NewRoutineView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var routineName = ""
    @State private var selectedType: RoutineType = .morning
    @State private var selectedIcon = ""
    @State private var targetTime = 30
    @State private var enableNotification = false
    @State private var notificationTime = Date()
    @State private var steps: [RoutineStep] = []
    @State private var showSuggestions = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Routine Details") {
                    TextField("Routine Name", text: $routineName)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(RoutineType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: "")
                                .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.mindLabsPurple)
                    .onChange(of: selectedType) { newType in
                        selectedIcon = newType.defaultIcon
                        if routineName.isEmpty {
                            routineName = "\(newType.rawValue) Routine"
                        }
                        if showSuggestions && steps.isEmpty {
                            loadSuggestedSteps()
                        }
                    }
                    
                    HStack {
                        Text("Icon")
                            .foregroundColor(.mindLabsText)
                        Spacer()
                        Text(selectedIcon.isEmpty ? selectedType.defaultIcon : selectedIcon)
                            .font(.system(size: 30))
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Target Time") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(targetTime) minutes")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsPurple)
                        
                        Slider(value: Binding(
                            get: { Double(targetTime) },
                            set: { targetTime = Int($0) }
                        ), in: 10...120, step: 5)
                        .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Notification") {
                    Toggle("Daily Reminder", isOn: $enableNotification)
                        .tint(.mindLabsPurple)
                    
                    if enableNotification {
                        DatePicker("Reminder Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                            .tint(.mindLabsPurple)
                    }
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Steps") {
                    if steps.isEmpty && showSuggestions {
                        Button(action: loadSuggestedSteps) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Use suggested steps for \(selectedType.rawValue)")
                                    .foregroundColor(.mindLabsText)
                                Spacer()
                            }
                        }
                    } else {
                        ForEach(steps.indices, id: \.self) { index in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.mindLabsTextSecondary)
                                    .frame(width: 20)
                                Text(steps[index].icon)
                                Text(steps[index].title)
                                    .foregroundColor(.mindLabsText)
                                Spacer()
                                Text("\(steps[index].estimatedTime) min")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        .onDelete(perform: deleteStep)
                        .onMove(perform: moveStep)
                        
                        Button(action: {
                            // Add custom step functionality
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.mindLabsPurple)
                                Text("Add Step")
                                    .foregroundColor(.mindLabsPurple)
                            }
                        }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                
                trailing: Button("Create") {
                    createRoutine()
                }
                .foregroundColor(.mindLabsPurple)
                .disabled(routineName.isEmpty || steps.isEmpty)
            )
        }
        .onAppear {
            selectedIcon = selectedType.defaultIcon
            routineName = "\(selectedType.rawValue) Routine"
        }
    }
    
    private func loadSuggestedSteps() {
        steps = selectedType.suggestedSteps.enumerated().map { index, suggestion in
            RoutineStep(
                title: suggestion.title,
                icon: suggestion.icon,
                estimatedTime: suggestion.time,
                order: index
            )
        }
        targetTime = steps.reduce(0) { $0 + $1.estimatedTime }
    }
    
    private func deleteStep(at offsets: IndexSet) {
        steps.remove(atOffsets: offsets)
        updateStepOrder()
    }
    
    private func moveStep(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
        updateStepOrder()
    }
    
    private func updateStepOrder() {
        for index in steps.indices {
            steps[index].order = index
        }
    }
    
    private func createRoutine() {
        let routine = Routine(
            name: routineName,
            icon: selectedIcon.isEmpty ? selectedType.defaultIcon : selectedIcon,
            type: selectedType,
            steps: steps,
            targetTime: targetTime,
            notificationTime: enableNotification ? notificationTime : nil
        )
        
        gameManager.addRoutine(routine)
        
        if enableNotification {
            gameManager.scheduleRoutineNotification(routine)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditRoutineView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @State var routine: Routine
    
    var body: some View {
        NavigationView {
            Form {
                Section("Routine Details") {
                    TextField("Routine Name", text: $routine.name)
                        .textFieldStyle(MindLabsTextFieldStyle())
                    
                    Toggle("Active", isOn: $routine.isActive)
                        .tint(.mindLabsPurple)
                }
                .listRowBackground(Color.mindLabsCard)
                
                Section("Steps") {
                    ForEach(routine.steps.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .foregroundColor(.mindLabsTextSecondary)
                                .frame(width: 20)
                            Text(routine.steps[index].icon)
                            Text(routine.steps[index].title)
                                .foregroundColor(.mindLabsText)
                            Spacer()
                            Toggle("Optional", isOn: $routine.steps[index].isOptional)
                                .tint(.mindLabsPurple)
                        }
                    }
                }
                .listRowBackground(Color.mindLabsCard)
            }
            .background(Color.mindLabsBackground)
            .navigationTitle("Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple),
                
                trailing: Button("Save") {
                    gameManager.updateRoutine(routine)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
        }
    }
}

struct RoutinesView_Previews: PreviewProvider {
    static var previews: some View {
        RoutinesView()
            .environmentObject(GameManager())
    }
}