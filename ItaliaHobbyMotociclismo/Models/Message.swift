import Foundation

/// A chat message belonging to a specific event's chat room.
struct Message: Codable, Identifiable, Equatable {
    var id: String
    var eventId: String
    var senderId: String
    var senderNickname: String
    var text: String
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case eventId         = "event_id"
        case senderId        = "sender_id"
        case senderNickname  = "sender_nickname"
        case text
        case timestamp
    }
}
