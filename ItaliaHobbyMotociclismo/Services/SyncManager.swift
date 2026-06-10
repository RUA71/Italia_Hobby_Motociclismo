import Foundation
import Combine

/// Periodically syncs events and subscribed chat messages in the background.
final class SyncManager {
    static let shared = SyncManager()
    private var timer: Timer?
    private let interval: TimeInterval = 30 // seconds

    private let eventRepo = EventRepository.shared
    private let chatRepo  = ChatRepository.shared
    private let userRepo  = UserRepository.shared

    private init() {}

    // MARK: - Lifecycle

    func startSync() {
        stopSync()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.performSync() }
        }
        // Run immediately
        Task { await self.performSync() }
    }

    func stopSync() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Sync Logic

    @MainActor
    private func performSync() async {
        guard let userId = userRepo.currentUserId else { return }

        // Sync events (with subscription state for this user)
        do {
            _ = try await eventRepo.fetchEvents(userId: userId)
        } catch {
            print("SyncManager: events sync failed – \(error.localizedDescription)")
        }

        // Sync messages for subscribed events
        let subscribedEvents = CoreDataManager.shared.fetchEvents().filter { $0.isSubscribed }
        for event in subscribedEvents {
            do {
                _ = try await chatRepo.fetchMessages(for: event.id, userId: userId)
            } catch {
                print("SyncManager: chat sync failed for event \(event.id) – \(error.localizedDescription)")
            }
        }
    }
}
