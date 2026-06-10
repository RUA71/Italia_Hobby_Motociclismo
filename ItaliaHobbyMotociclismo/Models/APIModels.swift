import Foundation

// MARK: - API Response Wrappers

struct APIResponse<T: Decodable>: Decodable {
    let data: T
    let message: String?
}

struct EmptyResponse: Decodable {}

// MARK: - Request Bodies

struct SubscriptionRequest: Encodable {
    let userId: String
    let eventId: String

    enum CodingKeys: String, CodingKey {
        case userId  = "user_id"
        case eventId = "event_id"
    }
}

struct SendMessageRequest: Encodable {
    let userId: String
    let senderNickname: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case userId         = "user_id"
        case senderNickname = "sender_nickname"
        case text
    }
}
