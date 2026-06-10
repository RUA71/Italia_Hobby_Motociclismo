import Foundation
import SwiftUI

/// Manages profile editing.
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isEditing = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let userRepo = UserRepository.shared

    init(user: User) {
        self.user = user
    }

    // MARK: - Save Changes

    func saveProfile() async {
        isSaving = true
        defer { isSaving = false }
        errorMessage = nil
        do {
            let updated: User = try await APIClient.shared.request(
                endpoint: .registerUser,
                body: user
            )
            self.user = updated
            userRepo.saveLocally(updated)
        } catch {
            // Save locally even if network fails
            userRepo.saveLocally(user)
        }
        isEditing = false
    }
}
