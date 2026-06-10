import Foundation

/// Handles all Chat-related remote and local operations.
final class ChatRepository {
    static let shared = ChatRepository()
    private let api = APIClient.shared
    private let db  = CoreDataManager.shared

    private init() {}

    // MARK: - Fetch Messages

    /// Fetches remote messages, merges into local DB, returns combined list.
    func fetchMessages(for eventId: String) async throws -> [Message] {
        let remote: [Message] = try await api.request(endpoint: .getChat(eventId: eventId))
        db.saveMessages(remote)
        return db.fetchMessages(for: eventId)
    }

    /// Returns locally cached messages for offline support.
    func cachedMessages(for eventId: String) -> [Message] {
        db.fetchMessages(for: eventId)
    }

    // MARK: - Send Message

    func sendMessage(eventId: String, userId: String, nickname: String, text: String) async throws -> Message {
        let body = SendMessageRequest(userId: userId, senderNickname: nickname, text: text)
        let message: Message = try await api.request(endpoint: .postMessage(eventId: eventId), body: body)
        db.saveMessages([message])
        return message
    }
}
