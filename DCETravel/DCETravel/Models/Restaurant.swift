import Foundation

struct Restaurant: Identifiable, Codable, Hashable {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

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
