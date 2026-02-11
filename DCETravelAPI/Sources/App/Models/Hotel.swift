import Foundation
import Vapor

struct Hotel: Identifiable, Codable {
    let id: UUID
    var name: String
    var brand: String
    var starRating: Int
    var userRating: Double
    var ratingCount: Int
    var location: String
    var locationDetail: String
    var pricePerNight: Double
    var totalPrice: Double
    var pointsCost: Int
    var originalPointsCost: Int
    var amenities: [String]
    var imageURLs: [String]
    var tier: HotelTier?
    var description: String

    enum HotelTier: String, Codable {
        case theEdit = "The Edit"
        case premium = "Premium"
        case luxury = "Luxury"
    }
}

extension Hotel: Content {}
