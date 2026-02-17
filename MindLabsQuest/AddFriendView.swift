import SwiftUI

struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var friendManager = FriendManager.shared
    @State private var searchText = ""
    @State private var selectedMethod: AddMethod = .username
    @State private var showingQRScanner = false
    @State private var showingShareSheet = false
    @State private var inviteMessage = "Join me on MindLabs Quest! Let's level up together 🎮"
    
    enum AddMethod: String, CaseIterable {
        case username = "Username"
        case qrCode = "QR Code"
        case contacts = "Contacts"
        case invite = "Invite"
        
        var icon: String {
            switch self {
            case .username: return "at"
            case .qrCode: return "qrcode"
            case .contacts: return "person.crop.circle"
            case .invite: return "square.and.arrow.up"
            }
        }
        
        var description: String {
            switch self {
            case .username: return "Search by username"
            case .qrCode: return "Scan a friend's QR code"
            case .contacts: return "Find friends from contacts"
            case .invite: return "Share invite link"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Method Selector
                    VStack(spacing: 15) {
                        ForEach(AddMethod.allCases, id: \.self) { method in
                            MethodCard(
                                method: method,
                                isSelected: selectedMethod == method
                            ) {
                                selectedMethod = method
                            }
                        }
                    }
                    .padding(.top)
                    
                    // Content based on selected method
                    switch selectedMethod {
                    case .username:
                        usernameSearchContent
                    case .qrCode:
                        qrCodeContent
                    case .contacts:
                        contactsContent
                    case .invite:
                        inviteContent
                    }
                }
                .padding()
            }
            .navigationTitle("Add Friend")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .mindLabsBackground()
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generateInviteLink()])
            }
        }
    }
    
    // MARK: - Username Search
    var usernameSearchContent: some View {
        VStack(spacing: 20) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.mindLabsTextSecondary)
                
                TextField("Enter username", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                }
            }
            .padding()
            .background(Color.mindLabsCard)
            .cornerRadius(10)
            
            // Search Results (Demo)
            if !searchText.isEmpty {
                VStack(spacing: 15) {
                    Text("Search Results")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Demo search results
                    ForEach(generateDemoSearchResults(), id: \.username) { user in
                        SearchResultCard(user: user) {
                            sendFriendRequest(to: user)
                        }
                    }
                }
            }
            
            // Suggested Friends
            VStack(spacing: 15) {
                Label("Suggested Friends", systemImage: "person.2.fill")
                    .font(MindLabsTypography.headline())
                    .foregroundColor(.mindLabsText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(generateSuggestedFriends(), id: \.username) { user in
                    SearchResultCard(user: user) {
                        sendFriendRequest(to: user)
                    }
                }
            }
        }
    }
    
    // MARK: - QR Code
    var qrCodeContent: some View {
        VStack(spacing: 20) {
            // Your QR Code
            MindLabsCard {
                VStack(spacing: 15) {
                    Text("Your Friend Code")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    // QR Code placeholder
                    Image(systemName: "qrcode")
                        .font(.system(size: 150))
                        .foregroundColor(.mindLabsPurple)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    
                    Text("@yourUsername")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("Share QR Code", systemImage: "square.and.arrow.up")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
            
            // Scan Button
            Button(action: { showingQRScanner = true }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Scan Friend's Code")
                }
                .font(MindLabsTypography.subheadline())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.mindLabsPurple)
                .cornerRadius(10)
            }
        }
    }
    
    // MARK: - Contacts
    var contactsContent: some View {
        VStack(spacing: 20) {
            MindLabsCard {
                VStack(spacing: 15) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 50))
                        .foregroundColor(.mindLabsPurple)
                    
                    Text("Find Friends from Contacts")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("Connect your contacts to find friends who are already using MindLabs Quest")
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: requestContactsAccess) {
                        Text("Connect Contacts")
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mindLabsPurple)
                            .cornerRadius(10)
                    }
                }
            }
            
            // Privacy Note
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.mindLabsTextSecondary)
                Text("Your contacts are used only to find friends and are never stored")
                    .font(MindLabsTypography.caption2())
                    .foregroundColor(.mindLabsTextSecondary)
            }
            .padding()
            .background(Color.mindLabsCard.opacity(0.5))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Invite
    var inviteContent: some View {
        VStack(spacing: 20) {
            MindLabsCard {
                VStack(spacing: 15) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.mindLabsPurple)
                    
                    Text("Invite Friends")
                        .font(MindLabsTypography.headline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("Share your unique invite link with friends")
                        .font(MindLabsTypography.body())
                        .foregroundColor(.mindLabsTextSecondary)
                    
                    // Invite Message
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Customize Message")
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                        
                        TextEditor(text: $inviteMessage)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color.mindLabsBackground)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Invite Link")
                        }
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mindLabsPurple)
                        .cornerRadius(10)
                    }
                }
            }
            
            // Share Options
            HStack(spacing: 20) {
                ShareOptionButton(icon: "message.fill", title: "Message", color: .green)
                ShareOptionButton(icon: "envelope.fill", title: "Email", color: .blue)
                ShareOptionButton(icon: "link", title: "Copy Link", color: .orange)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generateDemoSearchResults() -> [DemoUser] {
        guard !searchText.isEmpty else { return [] }
        
        return [
            DemoUser(username: "\(searchText)123", displayName: "\(searchText.capitalized) Player", level: 15),
            DemoUser(username: "\(searchText)_pro", displayName: "\(searchText.capitalized) Pro", level: 22),
            DemoUser(username: "the\(searchText)", displayName: "The \(searchText.capitalized)", level: 8)
        ].filter { $0.username.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func generateSuggestedFriends() -> [DemoUser] {
        [
            DemoUser(username: "taskmaster", displayName: "Task Master", level: 30),
            DemoUser(username: "focuswarrior", displayName: "Focus Warrior", level: 18),
            DemoUser(username: "questseeker", displayName: "Quest Seeker", level: 25)
        ]
    }
    
    private func sendFriendRequest(to user: DemoUser) {
        friendManager.sendFriendRequest(
            to: user.username,
            message: "Hi! Let's be quest buddies!"
        )
        presentationMode.wrappedValue.dismiss()
    }
    
    private func requestContactsAccess() {
        // In a real app, request contacts permission
        print("Requesting contacts access")
    }
    
    private func generateInviteLink() -> String {
        return "\(inviteMessage)\n\nJoin here: https://mindlabsquest.app/invite/abc123"
    }
}

// MARK: - Supporting Views

struct MethodCard: View {
    let method: AddFriendView.AddMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            MindLabsCard {
                HStack(spacing: 15) {
                    Image(systemName: method.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .mindLabsPurple : .mindLabsTextSecondary)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(method.rawValue)
                            .font(MindLabsTypography.subheadline())
                            .foregroundColor(.mindLabsText)
                        
                        Text(method.description)
                            .font(MindLabsTypography.caption())
                            .foregroundColor(.mindLabsTextSecondary)
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.mindLabsPurple)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.mindLabsPurple : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct DemoUser {
    let username: String
    let displayName: String
    let level: Int
}

struct SearchResultCard: View {
    let user: DemoUser
    let onAdd: () -> Void
    
    var body: some View {
        MindLabsCard {
            HStack(spacing: 15) {
                // Avatar placeholder
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.mindLabsPurple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(MindLabsTypography.subheadline())
                        .foregroundColor(.mindLabsText)
                    
                    Text("@\(user.username) • Level \(user.level)")
                        .font(MindLabsTypography.caption())
                        .foregroundColor(.mindLabsTextSecondary)
                }
                
                Spacer()
                
                Button(action: onAdd) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.mindLabsPurple)
                }
            }
        }
    }
}

struct ShareOptionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(MindLabsTypography.caption())
                    .foregroundColor(.mindLabsText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AddFriendView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendView()
    }
}