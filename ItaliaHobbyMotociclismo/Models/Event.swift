import Foundation
import CoreLocation

/// Represents a motorbike club event.
struct Event: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var date: Date
    var latitude: Double
    var longitude: Double
    var participantCount: Int
    var isSubscribed: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case date
        case latitude
        case longitude
        case participantCount = "participant_count"
        case isSubscribed     = "is_subscribed"
    }
}
