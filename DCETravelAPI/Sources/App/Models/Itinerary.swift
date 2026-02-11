import Foundation
import Vapor

struct Itinerary: Identifiable, Codable {
    let id: UUID
    var selectedTheme: ItineraryTheme?
    var days: [ItineraryDay]
}

extension Itinerary: Content {}

struct ItineraryDay: Identifiable, Codable {
    let id: UUID
    var dayNumber: Int
    var date: Date
    var activities: [ItineraryActivity]
}

extension ItineraryDay: Content {}

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

extension ItineraryActivity: Content {}

struct ItineraryTheme: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var tags: [String]
    var imageURL: String
}

extension ItineraryTheme: Content {}
