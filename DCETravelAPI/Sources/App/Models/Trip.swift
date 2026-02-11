import Foundation
import Vapor

struct Trip: Identifiable, Codable {
    let id: UUID
    var name: String
    var destination: String
    var destinationCountry: String
    var imageURL: String
    var startDate: Date
    var endDate: Date
    var travelers: [String]
    var status: TripStatus
    var itinerary: Itinerary?
    var bookings: [UUID]

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: startDate)
        formatter.dateFormat = "MMM d"
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }

    var nightCount: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

extension Trip: Content {}

enum TripStatus: String, Codable {
    case planning = "Planning"
    case booked = "Booked"
    case active = "Active"
    case completed = "Completed"
}
