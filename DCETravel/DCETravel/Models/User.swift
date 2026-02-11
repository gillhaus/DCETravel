import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var pointsBalance: Int
    var membershipTier: MembershipTier
    var preferences: TravelPreferences
    var tripHistory: [UUID]

    var fullName: String { "\(firstName) \(lastName)" }

    enum MembershipTier: String, Codable, CaseIterable {
        case sapphire = "Sapphire"
        case preferred = "Sapphire Preferred"
        case reserve = "Sapphire Reserve"
    }
}

struct TravelPreferences: Codable {
    var preferredAirlines: [String]
    var preferredHotelChains: [String]
    var dietaryRestrictions: [String]
    var seatPreference: String
    var interests: [String]
}
