import SwiftUI

struct TimerView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    let quest: Quest?
    @State private var timeRemaining: Int
    @State private var isRunning = false
    @State private var timer: Timer?
    
    init(quest: Quest? = nil) {
        self.quest = quest
        self._timeRemaining = State(initialValue: (quest?.estimatedTime ?? 25) * 60)
    }
    
    var body: some View {
        NavigationView {
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
                        Text(timeString)
                            .font(.system(size: 60, weight: .thin, design: .monospaced))
                        
                        Text("minutes remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
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
            .navigationTitle("Focus Timer")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .toolbar {
                if quest != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    var progress: Double {
        let total = Double((quest?.estimatedTime ?? 25) * 60)
        return Double(timeRemaining) / total
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pauseTimer()
                // Play completion sound or haptic
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = (quest?.estimatedTime ?? 25) * 60
    }
}

// Standalone Timer View for Tab
struct StandaloneTimerView: View {
    @State private var selectedTime = 25
    @State private var showingTimer = false
    
    let presetTimes = [5, 10, 15, 25, 30, 45, 60]
    
    var body: some View {
        NavigationView {
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