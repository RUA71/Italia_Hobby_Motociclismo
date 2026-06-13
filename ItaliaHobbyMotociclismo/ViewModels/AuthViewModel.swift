import Foundation
import SwiftUI

/// Manages authentication state and registration.
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false

    private let userRepo = UserRepository.shared

    // MARK: - Init

    init() {
        Task { await loadCurrentUser() }
    }

    // MARK: - Load

    func loadCurrentUser() async {
        isLoading = true
        defer { isLoading = false }
        do {
            currentUser = try await userRepo.fetchCurrentUser()
            isRegistered = currentUser != nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Registration

    func register(
        nickname: String,
        name: String,
        surname: String,
        city: String,
        country: String,
        motorbikeBrand: String,
        motorbikeModel: String,
        motorbikeType: String
    ) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        let user = User(
            id: UUID().uuidString,
            nickname: nickname,
            name: name,
            surname: surname,
            city: city,
            country: country,
            motorbikeBrand: motorbikeBrand,
            motorbikeModel: motorbikeModel,
            motorbikeType: motorbikeType
        )

        do {
            let registered = try await userRepo.register(user: user)
            currentUser = registered
            isRegistered = true
        } catch {
            // Persist locally so the user can continue offline;
            // they'll be synced to the server when connectivity is restored.
            userRepo.saveLocally(user)
            currentUser = user
            isRegistered = true
            // Inform the user that the remote registration failed.
            errorMessage = String(localized: "Registration saved locally. It will be synced when you are back online.",
                                  comment: "Offline registration notice")
        }
    }

    // MARK: - Logout

    func logout() {
        userRepo.logout()
        currentUser = nil
        isRegistered = false
    }
}
