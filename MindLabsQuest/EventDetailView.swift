import SwiftUI

struct EventDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let event: CalendarEvent
    let onConvert: (Quest) -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Event Header
                    VStack(spacing: 15) {
                        Text(event.eventType.icon)
                            .font(.system(size: 60))
                            .frame(width: 100, height: 100)
                            .background(
                                LinearGradient(
                                    colors: [event.category.color.opacity(0.3), event.category.color.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .mindLabsCardShadow()
                        
                        Text(event.title)
                            .font(MindLabsTypography.title())
                            .foregroundColor(.mindLabsText)
                            .multilineTextAlignment(.center)
                        
                        if !event.courseOrSubject.isEmpty {
                            Text(event.courseOrSubject)
                                .font(MindLabsTypography.headline())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        HStack(spacing: 15) {
                            Label(event.eventType.rawValue, systemImage: "tag.fill")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsPurple)
                            
                            Label(event.category.rawValue, systemImage: event.category.icon)
                                .font(MindLabsTypography.caption())
                                .foregroundColor(event.category.color)
                        }
                    }
                    .padding()
                    
                    // Event Details
                    VStack(alignment: .leading, spacing: 20) {
                        // Priority Badge
                        HStack {
                            Text("Priority")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Spacer()
                            
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(event.priority.color)
                                    .frame(width: 10, height: 10)
                                Text(event.priority.rawValue)
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(event.priority.color)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(event.priority.color.opacity(0.2))
                            .cornerRadius(20)
                        }
                        
                        // Date & Time
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.mindLabsPurple)
                            Text(dateFormatter.string(from: event.date))
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                        }
                        
                        // Estimated Time
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.mindLabsPurple)
                            Text("Duration: \(event.duration) minutes")
                                .font(MindLabsTypography.body())
                                .foregroundColor(.mindLabsText)
                        }
                        
                        // Description
                        if !event.description.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Description")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                
                                Text(event.description)
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        // Quest Conversion Info
                        MindLabsCard {
                            VStack(spacing: 15) {
                                Text("Quest Rewards")
                                    .font(MindLabsTypography.headline())
                                    .foregroundColor(.mindLabsText)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Label("\(Int(Double(event.eventType.defaultDifficulty.xpReward) * event.priority.xpMultiplier)) XP", systemImage: "star.fill")
                                            .font(MindLabsTypography.title2())
                                            .foregroundColor(.mindLabsBlue)
                                        
                                        Text("Experience Points")
                                            .font(MindLabsTypography.caption())
                                            .foregroundColor(.mindLabsTextSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Label("\(Int(Double(event.eventType.defaultDifficulty.xpReward) * event.priority.xpMultiplier / 2)) Gold", systemImage: "bitcoinsign.circle.fill")
                                            .font(MindLabsTypography.title2())
                                            .foregroundColor(.yellow)
                                        
                                        Text("Gold Reward")
                                            .font(MindLabsTypography.caption())
                                            .foregroundColor(.mindLabsTextSecondary)
                                    }
                                }
                                
                                Text("Difficulty: \(event.eventType.defaultDifficulty.rawValue)")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsTextSecondary)
                            }
                        }
                        
                        // Convert to Quest Button
                        if !event.convertedToQuest {
                            Button(action: {
                                let quest = event.toQuest()
                                onConvert(quest)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Convert to Quest")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(MindLabsPrimaryButtonStyle())
                            .padding(.top, 10)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.mindLabsSuccess)
                                Text("Already converted to quest")
                                    .font(MindLabsTypography.body())
                                    .foregroundColor(.mindLabsSuccess)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mindLabsSuccess.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Delete Button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Event")
                            }
                            .foregroundColor(.mindLabsError)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mindLabsError.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .navigationBarItems(trailing:
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.mindLabsPurple)
            )
            .alert("Delete Event", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(
            event: CalendarEvent(
                title: "Math Final Exam",
                description: "Chapters 1-10",
                date: Date(),
                eventType: .exam,
                category: .academic,
                priority: .high,
                courseOrSubject: "Calculus II"
            ),
            onConvert: { _ in },
            onDelete: { }
        )
    }
}