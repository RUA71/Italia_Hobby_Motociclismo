import Foundation
import SwiftUI

/// Manages events list and subscription logic.
@MainActor
final class EventsViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let eventRepo = EventRepository.shared

    // MARK: - Load Events

    func loadEvents() async {
        // Show cached data immediately
        events = eventRepo.cachedEvents()
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            events = try await eventRepo.fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Subscribe / Unsubscribe

    func subscribe(to event: Event, userId: String) async {
        errorMessage = nil
        do {
            try await eventRepo.subscribe(userId: userId, eventId: event.id)
            // Optimistically update local state
            if let idx = events.firstIndex(where: { $0.id == event.id }) {
                events[idx].isSubscribed = true
                events[idx].participantCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func unsubscribe(from event: Event, userId: String) async {
        errorMessage = nil
        do {
            try await eventRepo.unsubscribe(userId: userId, eventId: event.id)
            if let idx = events.firstIndex(where: { $0.id == event.id }) {
                events[idx].isSubscribed = false
                events[idx].participantCount = max(0, events[idx].participantCount - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var subscribedEvents: [Event] {
        events.filter { $0.isSubscribed }
    }
}
