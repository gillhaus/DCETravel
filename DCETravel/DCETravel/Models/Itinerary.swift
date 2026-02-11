import Foundation

struct Itinerary: Identifiable, Codable, Hashable {
    let id: UUID
    var selectedTheme: ItineraryTheme?
    var days: [ItineraryDay]

    static func == (lhs: Itinerary, rhs: Itinerary) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ItineraryDay: Identifiable, Codable {
    let id: UUID
    var dayNumber: Int
    var date: Date
    var activities: [ItineraryActivity]
}

struct ItineraryActivity: Identifiable, Codable {
    let id: UUID
    var time: String
    var title: String
    var description: String
    var type: ActivityType
    var location: String?
    var imageURL: String?

    enum ActivityType: String, Codable {
        case sightseeing = "Sightseeing"
        case dining = "Dining"
        case hotel = "Hotel"
        case flight = "Flight"
        case activity = "Activity"
        case freeTime = "Free Time"
    }
}

struct ItineraryTheme: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var tags: [String]
    var imageURL: String
}
