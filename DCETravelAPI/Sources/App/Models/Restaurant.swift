import Foundation
import Vapor

struct Restaurant: Identifiable, Codable {
    let id: UUID
    var name: String
    var cuisine: String
    var rating: Double
    var priceLevel: String
    var imageURL: String
    var location: String
    var reservationDate: Date?
    var reservationTime: String?
    var guestCount: Int?
    var isBooked: Bool
    var description: String
}

extension Restaurant: Content {}
