import Foundation
import Vapor

struct Booking: Identifiable, Codable {
    let id: UUID
    var type: BookingType
    var status: BookingStatus
    var confirmationNumber: String
    var tripId: UUID
    var details: String
    var date: Date
    var sourceId: UUID?
    var price: Double?
    var pointsUsed: Int?
    var checkInDate: Date?
    var checkOutDate: Date?
    var passengers: [String]?
    var guestCount: Int?

    enum BookingType: String, Codable {
        case flight = "Flight"
        case hotel = "Hotel"
        case restaurant = "Restaurant"
        case carRental = "Car Rental"
        case lounge = "Lounge"
        case activity = "Activity"
    }

    enum BookingStatus: String, Codable {
        case pending = "Pending"
        case confirmed = "Confirmed"
        case cancelled = "Cancelled"
        case completed = "Completed"
    }
}

extension Booking: Content {}
