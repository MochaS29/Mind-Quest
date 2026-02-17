import SwiftUI
import UIKit

struct TimerView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.presentationMode) var presentationMode
    
    let quest: Quest?
    @State private var timeRemaining: Int
    @State private var totalTime: Int
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var showBreakAlert = false
    @State private var breakTime = 5 // minutes
    @State private var isBreakTime = false
    @State private var sessionCount = 0
    
    init(quest: Quest? = nil) {
        self.quest = quest
        let time = (quest?.estimatedTime ?? 25) * 60
        self._timeRemaining = State(initialValue: time)
        self._totalTime = State(initialValue: time)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                if let quest = quest {
                    // Quest Info
                    VStack(spacing: 10) {
                        Text(quest.category.icon)
                            .font(.system(size: 60))
                        
                        Text(quest.title)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Label("\(quest.xpReward) XP", systemImage: "star.fill")
                                .foregroundColor(.blue)
                            
                            Label("\(quest.goldReward) Gold", systemImage: "bitcoinsign.circle.fill")
                                .foregroundColor(.yellow)
                        }
                        .font(.caption)
                    }
                    .padding()
                }
                
                // Timer Display
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: timeRemaining)
                    
                    VStack {
                        if isBreakTime {
                            Text("Break Time")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        Text(timeString)
                            .font(.system(size: 60, weight: .thin, design: .monospaced))
                        
                        Text(isBreakTime ? "Recharge your energy" : "Stay focused")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if sessionCount > 0 {
                            Text("Sessions: \(sessionCount)")
                                .font(.caption2)
                                .foregroundColor(.purple)
                                .padding(.top, 5)
                        }
                    }
                }
                
                // Controls
                HStack(spacing: 30) {
                    Button(action: {
                        if isRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                    }
                    
                    Button(action: {
                        resetTimer()
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Complete Button
                if let quest = quest, timeRemaining == 0 {
                    Button(action: {
                        gameManager.completeQuest(quest)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Complete Quest")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            }
            .navigationTitle("Focus Timer")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing: Group {
                if quest != nil {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.mindLabsPurple)
                }
            })
        }
        .onDisappear {
            timer?.invalidate()
            notificationManager.cancelTimerNotifications()
        }
        .alert("Time for a Break!", isPresented: $showBreakAlert) {
            Button("Start \(breakTime) min break") {
                startBreak()
            }
            Button("Skip break") {
                timeRemaining = totalTime
                showBreakAlert = false
            }
        } message: {
            Text("Great job! You've completed a focus session. Taking regular breaks helps maintain productivity.")
        }
    }
    
    var progress: Double {
        if isBreakTime {
            return Double(timeRemaining) / Double(breakTime * 60)
        }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        isRunning = true
        
        // Start time tracking for quest
        if let quest = quest, !isBreakTime {
            gameManager.startTimeTracking(for: quest.id)
        }
        
        // Schedule notification for timer completion
        if !isBreakTime {
            notificationManager.scheduleTimerNotification(
                questTitle: quest?.title ?? "Focus Session",
                duration: TimeInterval(timeRemaining)
            )
            
            // Schedule break reminder after 25 minutes if session is longer
            if timeRemaining > 25 * 60 {
                notificationManager.scheduleBreakReminder(after: 25)
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pauseTimer()
                handleTimerComplete()
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Stop time tracking for quest
        if let quest = quest, !isBreakTime {
            gameManager.stopTimeTracking(for: quest.id)
        }
        
        // Cancel notifications if paused
        notificationManager.cancelTimerNotifications()
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = totalTime
        isBreakTime = false
        sessionCount = 0
    }
    
    func handleTimerComplete() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if isBreakTime {
            // Break is over, start new session
            isBreakTime = false
            timeRemaining = totalTime
            showBreakAlert = false
        } else {
            // Work session complete
            sessionCount += 1
            
            // Track focus minutes
            let focusMinutes = totalTime / 60
            gameManager.addFocusMinutes(focusMinutes)
            
            // After every 4 sessions, suggest a longer break
            if sessionCount % 4 == 0 {
                breakTime = 15 // Longer break
            } else {
                breakTime = 5 // Short break
            }
            
            showBreakAlert = true
        }
    }
    
    func startBreak() {
        isBreakTime = true
        timeRemaining = breakTime * 60
        showBreakAlert = false
        startTimer()
    }
}

// Standalone Timer View for Tab
struct StandaloneTimerView: View {
    @State private var selectedTime = 25
    @State private var showingTimer = false
    
    let presetTimes = [5, 10, 15, 25, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("⏱️")
                    .font(.system(size: 100))
                
                Text("Focus Timer")
                    .font(.title)
                    .bold()
                
                Text("Select a duration and start focusing!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Preset Times
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(presetTimes, id: \.self) { time in
                        Button(action: {
                            selectedTime = time
                        }) {
                            Text("\(time)")
                                .font(.headline)
                                .frame(width: 80, height: 80)
                                .background(selectedTime == time ? Color.purple : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTime == time ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
                
                // Custom Time Picker
                HStack {
                    Text("Custom:")
                    Stepper("\(selectedTime) minutes", value: $selectedTime, in: 1...120, step: 5)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                // Start Button
                Button(action: {
                    showingTimer = true
                }) {
                    Text("Start Timer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
            }
            .padding()
            }
            .navigationTitle("Focus Timer")
            .sheet(isPresented: $showingTimer) {
                TimerView(quest: Quest(
                    title: "Focus Session",
                    category: .academic,
                    difficulty: .medium,
                    estimatedTime: selectedTime
                ))
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimerView(quest: Quest(
                title: "Study for Math Test",
                category: .academic,
                difficulty: .hard,
                estimatedTime: 25
            ))
            .environmentObject(GameManager())
            
            StandaloneTimerView()
                .environmentObject(GameManager())
        }
    }
}