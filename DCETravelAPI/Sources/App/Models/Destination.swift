import Foundation
import Vapor

struct Destination: Identifiable, Codable {
    let id: UUID
    var name: String
    var country: String
    var imageURL: String
    var tags: [String]
    var description: String
    var suggestedDates: String?
    var category: DestinationCategory

    enum DestinationCategory: String, Codable {
        case trending = "Trending"
        case inspiration = "Inspiration"
        case recommended = "Based on your recent trip"
        case popular = "Popular"
    }
}

extension Destination: Content {}
