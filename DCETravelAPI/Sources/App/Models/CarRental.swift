import Foundation
import Vapor

struct CarRental: Identifiable, Codable {
    let id: UUID
    var company: String
    var carType: CarType
    var model: String
    var pricePerDay: Double
    var totalPrice: Double
    var pointsCost: Int
    var pickupLocation: String
    var dropoffLocation: String
    var imageURL: String
    var features: [String]
    var seating: Int

    enum CarType: String, Codable {
        case economy = "Economy"
        case compact = "Compact"
        case midsize = "Midsize"
        case suv = "SUV"
        case luxury = "Luxury"
    }
}

extension CarRental: Content {}
