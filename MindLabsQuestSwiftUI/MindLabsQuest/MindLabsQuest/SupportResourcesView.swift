import SwiftUI

struct SupportResourcesView: View {
    @State private var selectedCategory: ResourceCategory = .gettingStarted
    @State private var searchText = ""
    @State private var showingResourceDetail: ResourceItem?
    @State private var savedResources: Set<String> = []
    
    enum ResourceCategory: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case adhdTips = "ADHD Tips"
        case strategies = "Strategies"
        case videos = "Videos"
        case articles = "Articles"
        case community = "Community"
        
        var icon: String {
            switch self {
            case .gettingStarted: return "play.circle.fill"
            case .adhdTips: return "brain"
            case .strategies: return "lightbulb.fill"
            case .videos: return "play.rectangle.fill"
            case .articles: return "doc.text.fill"
            case .community: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    TextField("Search resources...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                    }
                }
                .padding()
                .background(Color.mindLabsCard)
                .padding()
                
                // Category Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(ResourceCategory.allCases, id: \.self) { category in
                            CategoryTab(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedCategory {
                        case .gettingStarted:
                            gettingStartedContent
                        case .adhdTips:
                            adhdTipsContent
                        case .strategies:
                            strategiesContent
                        case .videos:
                            videosContent
                        case .articles:
                            articlesContent
                        case .community:
                            communityContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Support Resources")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
            .sheet(item: $showingResourceDetail) { resource in
                ResourceDetailView(resource: resource, isSaved: savedResources.contains(resource.id)) {
                    toggleSaveResource(resource)
                }
            }
        }
        .onAppear {
            loadSavedResources()
        }
    }
    
    // MARK: - Getting Started Content
    var gettingStartedContent: some View {
        VStack(spacing: 20) {
            // Welcome Card
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "hand.wave.fill")
                            .font(.title)
                            .foregroundColor(.mindLabsPurple)
                        
                        Text("Welcome to MindLabs Quest!")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                    }
                    
                    Text("Transform your daily tasks into epic adventures. Here's how to get started:")
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Quick Start Guide
            ForEach(getQuickStartSteps(), id: \.title) { step in
                QuickStartStepCard(step: step)
            }
            
            // Tutorial Videos
            SectionHeader(title: "Tutorial Videos", icon: "play.circle")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    VideoThumbnail(
                        title: "Creating Your First Quest",
                        duration: "2:30",
                        thumbnail: "play.rectangle.fill"
                    )
                    
                    VideoThumbnail(
                        title: "Understanding XP & Levels",
                        duration: "3:15",
                        thumbnail: "chart.line.uptrend.xyaxis"
                    )
                    
                    VideoThumbnail(
                        title: "Using Focus Mode",
                        duration: "4:00",
                        thumbnail: "moon.fill"
                    )
                }
            }
        }
    }
    
    // MARK: - ADHD Tips Content
    var adhdTipsContent: some View {
        VStack(spacing: 20) {
            // Featured Tip
            FeaturedTipCard(
                title: "The Two-Minute Rule",
                description: "If a task takes less than 2 minutes, do it immediately. This prevents small tasks from piling up and becoming overwhelming.",
                icon: "clock.fill",
                color: .orange
            )
            
            // Tips Categories
            ForEach(getADHDTipCategories(), id: \.title) { category in
                TipCategoryCard(category: category) {
                    showingResourceDetail = ResourceItem(
                        id: category.title,
                        title: category.title,
                        description: category.description,
                        type: .article,
                        content: category.tips.joined(separator: "\n\n"),
                        estimatedTime: "5 min read"
                    )
                }
            }
            
            // Expert Advice
            SectionHeader(title: "Expert Advice", icon: "person.crop.circle.badge.checkmark")
            
            ExpertAdviceCard(
                expert: "Dr. Sarah Johnson",
                title: "ADHD & Executive Function",
                quote: "Breaking tasks into smaller, manageable pieces is key to overcoming executive dysfunction.",
                credentials: "Clinical Psychologist, ADHD Specialist"
            )
        }
    }
    
    // MARK: - Strategies Content
    var strategiesContent: some View {
        VStack(spacing: 20) {
            ForEach(getStrategyCategories(), id: \.title) { strategy in
                StrategyCard(strategy: strategy) {
                    showingResourceDetail = ResourceItem(
                        id: strategy.title,
                        title: strategy.title,
                        description: strategy.description,
                        type: .article,
                        content: strategy.techniques.map { "• \($0)" }.joined(separator: "\n"),
                        estimatedTime: "7 min read"
                    )
                }
            }
        }
    }
    
    // MARK: - Videos Content
    var videosContent: some View {
        VStack(spacing: 20) {
            // Video Categories
            ForEach(getVideoCategories(), id: \.title) { category in
                VStack(alignment: .leading, spacing: 15) {
                    Text(category.title)
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(category.videos, id: \.title) { video in
                                VideoCard(video: video)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Articles Content
    var articlesContent: some View {
        VStack(spacing: 15) {
            ForEach(getArticles().filter { article in
                searchText.isEmpty ||
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.description.localizedCaseInsensitiveContains(searchText)
            }, id: \.id) { article in
                ArticleCard(
                    article: article,
                    isSaved: savedResources.contains(article.id)
                ) {
                    showingResourceDetail = article
                } onSave: {
                    toggleSaveResource(article)
                }
            }
        }
    }
    
    // MARK: - Community Content
    var communityContent: some View {
        VStack(spacing: 20) {
            // Community Guidelines
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    Label("Community Guidelines", systemImage: "info.circle.fill")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("Our community is built on support, understanding, and respect. We're all on this journey together!")
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
            
            // Community Resources
            ForEach(getCommunityResources(), id: \.title) { resource in
                CommunityResourceCard(resource: resource)
            }
            
            // Support Groups
            SectionHeader(title: "Support Groups", icon: "person.3.fill")
            
            VStack(spacing: 15) {
                SupportGroupCard(
                    name: "Morning Motivators",
                    description: "Start your day with accountability and encouragement",
                    members: 156,
                    meetingTime: "Daily at 8:00 AM"
                )
                
                SupportGroupCard(
                    name: "Focus Warriors",
                    description: "Deep work sessions with body doubling support",
                    members: 89,
                    meetingTime: "Weekdays at 2:00 PM"
                )
                
                SupportGroupCard(
                    name: "Weekend Warriors",
                    description: "Tackle weekend tasks together",
                    members: 234,
                    meetingTime: "Saturdays at 10:00 AM"
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadSavedResources() {
        if let data = UserDefaults.standard.data(forKey: "savedResources"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            savedResources = decoded
        }
    }
    
    private func toggleSaveResource(_ resource: ResourceItem) {
        if savedResources.contains(resource.id) {
            savedResources.remove(resource.id)
        } else {
            savedResources.insert(resource.id)
        }
        
        if let encoded = try? JSONEncoder().encode(savedResources) {
            UserDefaults.standard.set(encoded, forKey: "savedResources")
        }
    }
}

// MARK: - Data Models

struct ResourceItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let type: ResourceType
    let content: String
    let estimatedTime: String
    
    enum ResourceType {
        case article, video, guide, tip
    }
}

struct QuickStartStep {
    let number: Int
    let title: String
    let description: String
    let icon: String
}

struct TipCategory {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let tips: [String]
}

struct Strategy {
    let title: String
    let description: String
    let icon: String
    let techniques: [String]
}

struct VideoCategory {
    let title: String
    let videos: [Video]
}

struct Video {
    let title: String
    let duration: String
    let thumbnail: String
}

struct CommunityResource {
    let title: String
    let description: String
    let icon: String
    let link: String
}

// MARK: - Supporting Views

struct CategoryTab: View {
    let category: SupportResourcesView.ResourceCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsTextSecondary)
                
                Text(category.rawValue)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.mindLabsPurple.opacity(0.1) : Color.clear)
            )
        }
    }
}

struct QuickStartStepCard: View {
    let step: QuickStartStep
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.mindLabsPurple.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text("\(step.number)")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsPurple)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(step.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: step.icon)
                    .foregroundColor(.mindLabsPurple)
            }
        }
    }
}

struct FeaturedTipCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                    
                    Text("Featured Tip")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                
                Text(title)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text(description)
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

struct TipCategoryCard: View {
    let category: TipCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MindLabsCard {
                HStack(spacing: 15) {
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(category.color)
                        .frame(width: 50, height: 50)
                        .background(category.color.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.title)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(category.description)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.mindLabsTextSecondary)
                }
            }
        }
    }
}

struct ExpertAdviceCard: View {
    let expert: String
    let title: String
    let quote: String
    let credentials: String
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title)
                        .foregroundColor(.mindLabsPurple)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(expert)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(credentials)
                            .font(MindLabsTypography.caption2())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                }
                
                Text(title)
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                
                Text("\"\(quote)\"")
                    .font(MindLabsTypography.body())
                    .foregroundColor(.mindLabsTextSecondary)
                    .italic()
            }
        }
    }
}

struct StrategyCard: View {
    let strategy: Strategy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: strategy.icon)
                            .font(.title2)
                            .foregroundColor(.mindLabsPurple)
                        
                        Text(strategy.title)
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.mindLabsPurple)
                    }
                    
                    Text(strategy.description)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                        .lineLimit(3)
                    
                    HStack {
                        ForEach(strategy.techniques.prefix(3), id: \.self) { technique in
                            Text("• \(technique)")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}

struct VideoThumbnail: View {
    let title: String
    let duration: String
    let thumbnail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.mindLabsPurple.opacity(0.2))
                    .frame(width: 160, height: 90)
                    .overlay(
                        Image(systemName: thumbnail)
                            .font(.title)
                            .foregroundColor(.mindLabsPurple)
                    )
                
                Text(duration)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .padding(4)
            }
            
            Text(title)
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsText)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
        }
    }
}

struct VideoCard: View {
    let video: Video
    
    var body: some View {
        Button(action: {}) {
            VideoThumbnail(
                title: video.title,
                duration: video.duration,
                thumbnail: video.thumbnail
            )
        }
    }
}

struct ArticleCard: View {
    let article: ResourceItem
    let isSaved: Bool
    let onTap: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            MindLabsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.title)
                                .font(MindLabsTypography.subheadline())
                                .foregroundColor(.mindLabsText)
                                .multilineTextAlignment(.leading)
                            
                            Text(article.estimatedTime)
                                .font(MindLabsTypography.caption2())
                                .foregroundColor(.mindLabsTextSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: onSave) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.mindLabsPurple)
                        }
                    }
                    
                    Text(article.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

struct CommunityResourceCard: View {
    let resource: CommunityResource
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                Image(systemName: resource.icon)
                    .font(.title2)
                    .foregroundColor(.mindLabsPurple)
                    .frame(width: 50, height: 50)
                    .background(Color.mindLabsPurple.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text(resource.description)
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.mindLabsPurple)
            }
        }
    }
}

struct SupportGroupCard: View {
    let name: String
    let description: String
    let members: Int
    let meetingTime: String
    
    var body: some View {
        MindLabsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(name)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Label("\(members)", systemImage: "person.2")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsPurple)
                }
                
                Text(description)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsTextSecondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.mindLabsPurple)
                    Text(meetingTime)
                        .font(MindLabsTypography.caption2())
                        .foregroundColor(.mindLabsText)
                    
                    Spacer()
                    
                    Button("Join") {
                        // Join group
                    }
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.mindLabsPurple)
                    .cornerRadius(15)
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(MindLabsTypography.headline())
                .foregroundColor(.mindLabsText)
            
            Spacer()
        }
    }
}

// MARK: - Resource Detail View
struct ResourceDetailView: View {
    let resource: ResourceItem
    let isSaved: Bool
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text(resource.title)
                            .font(MindLabsTypography.largeTitle())
                            .foregroundColor(.mindLabsText)
                        
                        HStack {
                            Label(resource.estimatedTime, systemImage: "clock")
                                .font(MindLabsTypography.caption())
                                .foregroundColor(.mindLabsTextSecondary)
                            
                            Spacer()
                            
                            Button(action: onSave) {
                                Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(MindLabsTypography.caption())
                                    .foregroundColor(.mindLabsPurple)
                            }
                        }
                    }
                    .padding()
                    
                    // Content
                    Text(resource.content)
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsText)
                        .padding(.horizontal)
                    
                    // Related Resources
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Related Resources")
                            .font(MindLabsTypography.headline())
                            .foregroundColor(.mindLabsText)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(1...3, id: \.self) { _ in
                                    RelatedResourceCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .mindLabsBackground()
        }
    }
}

struct RelatedResourceCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.mindLabsPurple.opacity(0.2))
                .frame(width: 150, height: 80)
            
            Text("Related Article")
                .font(MindLabsTypography.caption())
                .foregroundColor(.mindLabsText)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)
        }
    }
}

// MARK: - Data Providers

extension SupportResourcesView {
    func getQuickStartSteps() -> [QuickStartStep] {
        [
            QuickStartStep(
                number: 1,
                title: "Create Your Character",
                description: "Choose your avatar and class to begin your journey",
                icon: "person.crop.circle.badge.plus"
            ),
            QuickStartStep(
                number: 2,
                title: "Add Your First Quest",
                description: "Transform a task into an adventure",
                icon: "plus.circle.fill"
            ),
            QuickStartStep(
                number: 3,
                title: "Complete & Level Up",
                description: "Earn XP and unlock achievements",
                icon: "checkmark.circle.fill"
            ),
            QuickStartStep(
                number: 4,
                title: "Build Your Streak",
                description: "Stay consistent and watch your progress grow",
                icon: "flame.fill"
            )
        ]
    }
    
    func getADHDTipCategories() -> [TipCategory] {
        [
            TipCategory(
                title: "Focus & Attention",
                description: "Strategies to improve concentration",
                icon: "eye.fill",
                color: .blue,
                tips: [
                    "Use the Pomodoro Technique with short breaks",
                    "Eliminate distractions before starting",
                    "Work during your peak focus hours",
                    "Use white noise or focus music"
                ]
            ),
            TipCategory(
                title: "Organization",
                description: "Keep your tasks and life organized",
                icon: "folder.fill",
                color: .green,
                tips: [
                    "Everything needs a home",
                    "Use visual reminders and sticky notes",
                    "Break large projects into tiny steps",
                    "Review and plan daily"
                ]
            ),
            TipCategory(
                title: "Time Management",
                description: "Make the most of your time",
                icon: "clock.fill",
                color: .orange,
                tips: [
                    "Time block your calendar",
                    "Add buffer time between tasks",
                    "Set multiple alarms and reminders",
                    "Use timers for everything"
                ]
            ),
            TipCategory(
                title: "Emotional Regulation",
                description: "Manage emotions and stress",
                icon: "heart.fill",
                color: .pink,
                tips: [
                    "Practice mindfulness daily",
                    "Take regular movement breaks",
                    "Use breathing exercises",
                    "Celebrate small wins"
                ]
            )
        ]
    }
    
    func getStrategyCategories() -> [Strategy] {
        [
            Strategy(
                title: "Task Initiation",
                description: "Overcome the hardest part - getting started",
                icon: "play.fill",
                techniques: [
                    "Start with the smallest possible step",
                    "Use the 5-minute rule",
                    "Pair tasks with rewards",
                    "Body double with a friend",
                    "Change your environment"
                ]
            ),
            Strategy(
                title: "Hyperfocus Management",
                description: "Harness hyperfocus productively",
                icon: "scope",
                techniques: [
                    "Set clear time boundaries",
                    "Use alarms and timers",
                    "Schedule hyperfocus sessions",
                    "Plan transition activities",
                    "Keep healthy snacks nearby"
                ]
            ),
            Strategy(
                title: "Working Memory Support",
                description: "Compensate for working memory challenges",
                icon: "brain",
                techniques: [
                    "Write everything down immediately",
                    "Use voice recordings",
                    "Create visual cues",
                    "Repeat important information",
                    "Use checklists for routines"
                ]
            )
        ]
    }
    
    func getVideoCategories() -> [VideoCategory] {
        [
            VideoCategory(
                title: "Quick Tips",
                videos: [
                    Video(title: "5-Minute Morning Routine", duration: "5:12", thumbnail: "sunrise.fill"),
                    Video(title: "Desk Organization Hacks", duration: "3:45", thumbnail: "tray.full.fill"),
                    Video(title: "Quick Focus Exercises", duration: "4:30", thumbnail: "bolt.fill")
                ]
            ),
            VideoCategory(
                title: "Deep Dives",
                videos: [
                    Video(title: "Understanding ADHD", duration: "15:30", thumbnail: "brain"),
                    Video(title: "Building Sustainable Habits", duration: "12:45", thumbnail: "arrow.triangle.2.circlepath"),
                    Video(title: "Medication & Lifestyle", duration: "18:20", thumbnail: "pills.fill")
                ]
            )
        ]
    }
    
    func getArticles() -> [ResourceItem] {
        [
            ResourceItem(
                id: "article1",
                title: "The Science Behind Gamification and ADHD",
                description: "How game mechanics can boost motivation and engagement for ADHD brains",
                type: .article,
                content: "Research shows that gamification taps into the ADHD brain's reward system...",
                estimatedTime: "8 min read"
            ),
            ResourceItem(
                id: "article2",
                title: "Building a Morning Routine That Sticks",
                description: "Create a consistent morning routine that works with your ADHD, not against it",
                type: .article,
                content: "Morning routines are crucial for ADHD management...",
                estimatedTime: "6 min read"
            ),
            ResourceItem(
                id: "article3",
                title: "Body Doubling: Your Secret Productivity Weapon",
                description: "Learn how working alongside others can dramatically improve focus",
                type: .article,
                content: "Body doubling is a powerful technique where...",
                estimatedTime: "5 min read"
            )
        ]
    }
    
    func getCommunityResources() -> [CommunityResource] {
        [
            CommunityResource(
                title: "ADHD Subreddit",
                description: "Connect with others who understand",
                icon: "bubble.left.and.bubble.right.fill",
                link: "reddit.com/r/adhd"
            ),
            CommunityResource(
                title: "Discord Server",
                description: "Real-time chat and support",
                icon: "message.fill",
                link: "discord.gg/mindlabs"
            ),
            CommunityResource(
                title: "Weekly Newsletter",
                description: "Tips and strategies delivered weekly",
                icon: "envelope.fill",
                link: "mindlabs.com/newsletter"
            )
        ]
    }
}

struct SupportResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        SupportResourcesView()
    }
}