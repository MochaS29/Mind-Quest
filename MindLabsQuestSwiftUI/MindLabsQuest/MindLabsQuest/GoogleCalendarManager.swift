import Foundation
import AuthenticationServices
import CryptoKit

class GoogleCalendarManager: NSObject, ObservableObject {
    static let shared = GoogleCalendarManager()
    
    // MARK: - OAuth Configuration
    private let clientID = "YOUR_GOOGLE_CLIENT_ID" // Replace with actual client ID
    private let redirectURI = "com.mindlabs.quest://oauth"
    private let authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
    private let tokenEndpoint = "https://oauth2.googleapis.com/token"
    private let calendarAPIEndpoint = "https://www.googleapis.com/calendar/v3"
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var calendars: [GoogleCalendar] = []
    @Published var authError: String?
    @Published var isSyncing = false
    
    // MARK: - Private Properties
    private var accessToken: String? {
        didSet {
            isAuthenticated = accessToken != nil
        }
    }
    private var refreshToken: String?
    private var codeVerifier: String?
    private var authSession: ASWebAuthenticationSession?
    
    override init() {
        super.init()
        loadStoredTokens()
    }
    
    // MARK: - Authentication
    func authenticate(presentationContext: ASWebAuthenticationPresentationContextProviding) {
        // Generate PKCE parameters
        codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier!)
        
        // Build authorization URL
        var components = URLComponents(string: authorizationEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/calendar.events"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "access_type", value: "offline")
        ]
        
        guard let authURL = components.url else {
            authError = "Failed to create authorization URL"
            return
        }
        
        // Start authentication session
        authSession = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "com.mindlabs.quest"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }
            
            if let error = error {
                self.authError = error.localizedDescription
                return
            }
            
            guard let callbackURL = callbackURL,
                  let code = self.extractCode(from: callbackURL) else {
                self.authError = "Failed to extract authorization code"
                return
            }
            
            self.exchangeCodeForToken(code: code)
        }
        
        authSession?.presentationContextProvider = presentationContext
        authSession?.prefersEphemeralWebBrowserSession = true
        authSession?.start()
    }
    
    private func exchangeCodeForToken(code: String) {
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": clientID,
            "code": code,
            "code_verifier": codeVerifier ?? "",
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI
        ]
        
        let body = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                DispatchQueue.main.async {
                    self?.authError = "Failed to exchange code for token"
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = tokenResponse.accessToken
                    self.refreshToken = tokenResponse.refreshToken
                    self.saveTokens()
                    self.fetchCalendars()
                }
            } catch {
                DispatchQueue.main.async {
                    self.authError = "Failed to decode token response"
                }
            }
        }.resume()
    }
    
    func signOut() {
        accessToken = nil
        refreshToken = nil
        calendars = []
        clearStoredTokens()
    }
    
    // MARK: - Calendar API
    func fetchCalendars() {
        guard let token = accessToken else { return }
        
        let url = URL(string: "\(calendarAPIEndpoint)/users/me/calendarList")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(CalendarListResponse.self, from: data)
                DispatchQueue.main.async {
                    self.calendars = response.items
                }
            } catch {
                print("Failed to decode calendars: \(error)")
            }
        }.resume()
    }
    
    func fetchEvents(
        calendarId: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([GoogleCalendarEvent]) -> Void
    ) {
        guard let token = accessToken else {
            completion([])
            return
        }
        
        let formatter = ISO8601DateFormatter()
        var components = URLComponents(string: "\(calendarAPIEndpoint)/calendars/\(calendarId)/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: formatter.string(from: startDate)),
            URLQueryItem(name: "timeMax", value: formatter.string(from: endDate)),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime")
        ]
        
        guard let url = components.url else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let response = try JSONDecoder().decode(EventsResponse.self, from: data)
                completion(response.items)
            } catch {
                print("Failed to decode events: \(error)")
                completion([])
            }
        }.resume()
    }
    
    func syncGoogleCalendarEvents(
        calendarId: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping ([CalendarEvent]) -> Void
    ) {
        isSyncing = true
        
        fetchEvents(calendarId: calendarId, startDate: startDate, endDate: endDate) { [weak self] googleEvents in
            let calendarEvents = googleEvents.compactMap { googleEvent -> CalendarEvent? in
                guard let startTime = googleEvent.start.dateTime ?? googleEvent.start.date else {
                    return nil
                }
                
                let endTime = googleEvent.end.dateTime ?? googleEvent.end.date ?? startTime
                let duration = Int(endTime.timeIntervalSince(startTime) / 60)
                
                return CalendarEvent(
                    title: googleEvent.summary ?? "Untitled Event",
                    description: googleEvent.description ?? "",
                    date: startTime,
                    duration: duration,
                    eventType: self?.determineEventType(from: googleEvent) ?? .other,
                    category: self?.determineCategory(from: googleEvent) ?? .academic,
                    priority: self?.determinePriority(from: googleEvent) ?? .medium,
                    courseOrSubject: "",
                    location: googleEvent.location ?? "",
                    reminder: self?.determineReminder(from: googleEvent),
                    calendarIdentifier: "google:\(googleEvent.id)"
                )
            }
            
            DispatchQueue.main.async {
                self?.isSyncing = false
                completion(calendarEvents)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
    
    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = verifier.data(using: .utf8)!
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    private func determineEventType(from event: GoogleCalendarEvent) -> CalendarEvent.EventType {
        let title = event.summary?.lowercased() ?? ""
        
        if title.contains("exam") || title.contains("test") || title.contains("quiz") {
            return .exam
        } else if title.contains("assignment") || title.contains("homework") {
            return .assignment
        } else if title.contains("meeting") {
            return .meeting
        } else if title.contains("class") || title.contains("lecture") {
            return .classSession
        }
        
        return .other
    }
    
    private func determineCategory(from event: GoogleCalendarEvent) -> TaskCategory {
        let title = event.summary?.lowercased() ?? ""
        let description = event.description?.lowercased() ?? ""
        let combined = title + " " + description
        
        if combined.contains("study") || combined.contains("homework") || combined.contains("class") {
            return .academic
        } else if combined.contains("exercise") || combined.contains("gym") || combined.contains("workout") {
            return .fitness
        } else if combined.contains("meeting") || combined.contains("social") {
            return .social
        }
        
        return .academic
    }
    
    private func determinePriority(from event: GoogleCalendarEvent) -> CalendarEvent.EventPriority {
        let title = event.summary?.lowercased() ?? ""
        
        if title.contains("urgent") || title.contains("important") {
            return .high
        } else if title.contains("exam") || title.contains("deadline") {
            return .high
        }
        
        return .medium
    }
    
    private func determineReminder(from event: GoogleCalendarEvent) -> ReminderTime? {
        // Google Calendar reminders are in the event, but for simplicity we'll default to 15 minutes
        return .fifteenMinutes
    }
    
    // MARK: - Token Storage
    private func saveTokens() {
        if let accessToken = accessToken {
            KeychainHelper.save(key: "google_access_token", data: accessToken.data(using: .utf8)!)
        }
        if let refreshToken = refreshToken {
            KeychainHelper.save(key: "google_refresh_token", data: refreshToken.data(using: .utf8)!)
        }
    }
    
    private func loadStoredTokens() {
        if let tokenData = KeychainHelper.load(key: "google_access_token"),
           let token = String(data: tokenData, encoding: .utf8) {
            accessToken = token
        }
        if let tokenData = KeychainHelper.load(key: "google_refresh_token"),
           let token = String(data: tokenData, encoding: .utf8) {
            refreshToken = token
        }
    }
    
    private func clearStoredTokens() {
        KeychainHelper.delete(key: "google_access_token")
        KeychainHelper.delete(key: "google_refresh_token")
    }
}

// MARK: - Data Models
struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct GoogleCalendar: Identifiable, Codable {
    let id: String
    let summary: String
    let description: String?
    let backgroundColor: String?
    let foregroundColor: String?
    let selected: Bool?
    let accessRole: String
    let primary: Bool?
}

struct CalendarListResponse: Codable {
    let items: [GoogleCalendar]
}

struct GoogleCalendarEvent: Codable {
    let id: String
    let summary: String?
    let description: String?
    let location: String?
    let start: EventDateTime
    let end: EventDateTime
    let recurringEventId: String?
    let recurrence: [String]?
}

struct EventDateTime: Codable {
    let date: Date?
    let dateTime: Date?
    let timeZone: String?
}

struct EventsResponse: Codable {
    let items: [GoogleCalendarEvent]
}

// MARK: - Keychain Helper
class KeychainHelper {
    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}