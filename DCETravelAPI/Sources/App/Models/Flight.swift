import Foundation
import Vapor

struct Flight: Identifiable, Codable {
    let id: UUID
    var airline: String
    var flightNumber: String
    var departureAirport: String
    var arrivalAirport: String
    var departureTime: Date
    var arrivalTime: Date
    var price: Double
    var pointsCost: Int
    var cabinClass: CabinClass
    var status: FlightStatus

    var durationText: String {
        let interval = arrivalTime.timeIntervalSince(departureTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    enum CabinClass: String, Codable {
        case economy = "Economy"
        case premiumEconomy = "Premium Economy"
        case business = "Business"
        case first = "First"
    }

    enum FlightStatus: String, Codable {
        case scheduled = "Scheduled"
        case delayed = "Delayed"
        case boarding = "Boarding"
        case inFlight = "In Flight"
        case landed = "Landed"
        case cancelled = "Cancelled"
    }
}

extension Flight: Content {}
