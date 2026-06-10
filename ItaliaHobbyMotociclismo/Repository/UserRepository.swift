import Foundation

/// Handles all User-related remote and local operations.
final class UserRepository {
    static let shared = UserRepository()
    private let api = APIClient.shared
    private let db  = CoreDataManager.shared
    private let keychain = KeychainManager.shared

    private init() {}

    // MARK: - Registration

    func register(user: User) async throws -> User {
        let result: User = try await api.request(endpoint: .registerUser, body: user)
        db.saveUser(result)
        keychain.save(result.id, for: "userId")
        return result
    }

    // MARK: - Fetch current user

    func fetchCurrentUser() async throws -> User? {
        guard let userId = keychain.load(for: "userId") else { return nil }
        // Try local first
        if let local = db.fetchUser(id: userId) { return local }
        // Fallback to remote
        let remote: User = try await api.request(endpoint: .getUser(userId: userId))
        db.saveUser(remote)
        return remote
    }

    // MARK: - Persist locally

    func saveLocally(_ user: User) {
        db.saveUser(user)
        keychain.save(user.id, for: "userId")
    }

    // MARK: - Logout

    func logout() {
        keychain.delete(for: "userId")
    }

    var currentUserId: String? {
        keychain.load(for: "userId")
    }
}
