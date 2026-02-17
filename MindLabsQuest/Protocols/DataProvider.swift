import Foundation

// MARK: - Data Provider Protocol
// Abstraction layer for social data operations.
// Currently backed by UserDefaults; designed for future Firebase migration.

protocol DataProvider {
    // Friend Management
    func fetchFriends(completion: @escaping (Result<[Friend], Error>) -> Void)
    func addFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFriend(_ friendId: UUID, completion: @escaping (Result<Void, Error>) -> Void)

    // Friend Requests
    func sendFriendRequest(to username: String, message: String, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchFriendRequests(completion: @escaping (Result<[FriendRequest], Error>) -> Void)
    func respondToFriendRequest(_ requestId: UUID, accept: Bool, completion: @escaping (Result<Void, Error>) -> Void)

    // Activities
    func fetchActivities(completion: @escaping (Result<[SharedActivity], Error>) -> Void)
    func postActivity(_ activity: SharedActivity, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - UserDefaults Data Provider
class UserDefaultsDataProvider: DataProvider {
    private let friendsKey = "mindlabs_friends"
    private let requestsKey = "mindlabs_friend_requests"
    private let activitiesKey = "mindlabs_friend_activities"

    func fetchFriends(completion: @escaping (Result<[Friend], Error>) -> Void) {
        if let data = UserDefaults.standard.data(forKey: friendsKey),
           let decoded = try? JSONDecoder().decode([Friend].self, from: data) {
            completion(.success(decoded))
        } else {
            completion(.success([]))
        }
    }

    func addFriend(_ friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchFriends { result in
            switch result {
            case .success(var friends):
                friends.append(friend)
                if let encoded = try? JSONEncoder().encode(friends) {
                    UserDefaults.standard.set(encoded, forKey: self.friendsKey)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeFriend(_ friendId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchFriends { result in
            switch result {
            case .success(var friends):
                friends.removeAll { $0.id == friendId }
                if let encoded = try? JSONEncoder().encode(friends) {
                    UserDefaults.standard.set(encoded, forKey: self.friendsKey)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func sendFriendRequest(to username: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchFriendRequests { result in
            switch result {
            case .success(var requests):
                let demoFriend = Friend(
                    username: username,
                    displayName: username.capitalized,
                    avatar: "🧙‍♂️",
                    level: Int.random(in: 1...20),
                    currentStreak: 0,
                    totalQuestsCompleted: 0
                )
                let request = FriendRequest(
                    fromUser: demoFriend,
                    toUserId: "current_user",
                    message: message
                )
                requests.append(request)
                if let encoded = try? JSONEncoder().encode(requests) {
                    UserDefaults.standard.set(encoded, forKey: self.requestsKey)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchFriendRequests(completion: @escaping (Result<[FriendRequest], Error>) -> Void) {
        if let data = UserDefaults.standard.data(forKey: requestsKey),
           let decoded = try? JSONDecoder().decode([FriendRequest].self, from: data) {
            completion(.success(decoded))
        } else {
            completion(.success([]))
        }
    }

    func respondToFriendRequest(_ requestId: UUID, accept: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchFriendRequests { result in
            switch result {
            case .success(var requests):
                if let index = requests.firstIndex(where: { $0.id == requestId }) {
                    if accept {
                        let friend = requests[index].fromUser
                        requests.remove(at: index)
                        if let encoded = try? JSONEncoder().encode(requests) {
                            UserDefaults.standard.set(encoded, forKey: self.requestsKey)
                        }
                        self.addFriend(friend) { _ in }
                    } else {
                        requests.remove(at: index)
                        if let encoded = try? JSONEncoder().encode(requests) {
                            UserDefaults.standard.set(encoded, forKey: self.requestsKey)
                        }
                    }
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchActivities(completion: @escaping (Result<[SharedActivity], Error>) -> Void) {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([SharedActivity].self, from: data) {
            completion(.success(decoded))
        } else {
            completion(.success([]))
        }
    }

    func postActivity(_ activity: SharedActivity, completion: @escaping (Result<Void, Error>) -> Void) {
        fetchActivities { result in
            switch result {
            case .success(var activities):
                activities.insert(activity, at: 0)
                if activities.count > 50 {
                    activities = Array(activities.prefix(50))
                }
                if let encoded = try? JSONEncoder().encode(activities) {
                    UserDefaults.standard.set(encoded, forKey: self.activitiesKey)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
