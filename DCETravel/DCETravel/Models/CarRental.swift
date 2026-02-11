import Foundation

struct CarRental: Identifiable, Codable, Hashable {
    static func == (lhs: CarRental, rhs: CarRental) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

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
