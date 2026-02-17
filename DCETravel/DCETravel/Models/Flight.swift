import Foundation

struct Flight: Identifiable, Codable, Hashable {
    static func == (lhs: Flight, rhs: Flight) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

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
    var gate: String?
    var terminal: String?
    var baggageClaim: String?

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
        case checkIn = "Check-in Open"
        case delayed = "Delayed"
        case boarding = "Boarding"
        case inFlight = "In Flight"
        case landed = "Landed"
        case cancelled = "Cancelled"
    }
}

struct FlightStatusInfo: Codable, Identifiable {
    var id: String { flightNumber }
    let flightNumber: String
    let airline: String
    let departureAirport: String
    let arrivalAirport: String
    let status: Flight.FlightStatus
    let departureTime: Date
    let arrivalTime: Date
    let gate: String?
    let terminal: String?
    let baggageClaim: String?
    let delayMinutes: Int?
    let progressPercent: Double?
}
