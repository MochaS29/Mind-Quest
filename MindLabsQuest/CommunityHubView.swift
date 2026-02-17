import SwiftUI

struct CommunityHubView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedFeature: CommunityFeature = .social
    
    enum CommunityFeature: String, CaseIterable {
        case social = "Social"
        case challenges = "Challenges"
        case support = "Support"
        
        var icon: String {
            switch self {
            case .social: return "person.2.fill"
            case .challenges: return "flag.fill"
            case .support: return "heart.fill"
            }
        }
        
        var description: String {
            switch self {
            case .social: return "Connect with friends"
            case .challenges: return "Compete in challenges"
            case .support: return "Resources & tips"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Feature Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(CommunityFeature.allCases, id: \.self) { feature in
                            FeatureButton(
                                feature: feature,
                                isSelected: selectedFeature == feature
                            ) {
                                selectedFeature = feature
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.mindLabsCard)
                
                // Content
                Group {
                    switch selectedFeature {
                    case .social:
                        SocialHubView()
                    case .challenges:
                        CommunityChallengesView()
                    case .support:
                        SupportResourcesView()
                    }
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
            .mindLabsBackground()
        }
    }
}

struct FeatureButton: View {
    let feature: CommunityHubView.CommunityFeature
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .mindLabsPurple)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.mindLabsPurple : Color.mindLabsPurple.opacity(0.1))
                    )
                
                Text(feature.rawValue)
                    .font(MindLabsTypography.subheadline())
                    .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsText)
                
                Text(feature.description)
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
        }
    }
}

struct CommunityHubView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityHubView()
            .environmentObject(GameManager())
    }
}