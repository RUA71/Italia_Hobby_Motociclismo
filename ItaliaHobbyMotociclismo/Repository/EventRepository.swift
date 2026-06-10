import Foundation

/// Handles all Event-related remote and local operations.
final class EventRepository {
    static let shared = EventRepository()
    private let api = APIClient.shared
    private let db  = CoreDataManager.shared

    private init() {}

    // MARK: - Fetch Events

    /// Returns cached events immediately, then fetches remote and updates local DB.
    func fetchEvents(userId: String? = nil) async throws -> [Event] {
        let remote: [Event] = try await api.request(endpoint: .getEvents(userId: userId))
        db.saveEvents(remote)
        return remote
    }

    func cachedEvents() -> [Event] {
        db.fetchEvents()
    }

    // MARK: - Subscribe

    func subscribe(userId: String, eventId: String) async throws {
        let body = SubscriptionRequest(userId: userId, eventId: eventId)
        try await api.requestEmpty(endpoint: .subscribeEvent, body: body)
        db.updateEventSubscription(eventId: eventId, isSubscribed: true)
    }

    // MARK: - Unsubscribe

    func unsubscribe(userId: String, eventId: String) async throws {
        let body = SubscriptionRequest(userId: userId, eventId: eventId)
        try await api.requestEmpty(endpoint: .unsubscribeEvent, body: body)
        db.updateEventSubscription(eventId: eventId, isSubscribed: false)
    }
}
