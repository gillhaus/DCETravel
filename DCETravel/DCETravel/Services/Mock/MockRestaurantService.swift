import Foundation

class MockRestaurantService: RestaurantServiceProtocol {
    func searchRestaurants(location: String, cuisine: String?) async -> [Restaurant] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        return MockData.restaurants
    }

    func getRestaurant(id: UUID) async -> Restaurant? {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return MockData.restaurants.first { $0.id == id }
    }

    func bookTable(restaurantId: UUID, date: Date, guests: Int) async -> Booking {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        let restaurant = MockData.restaurants.first { $0.id == restaurantId } ?? MockData.restaurants[0]
        return Booking(
            id: UUID(),
            type: .restaurant,
            status: .confirmed,
            confirmationNumber: "RS\(Int.random(in: 100000...999999))",
            tripId: UUID(),
            details: "\(restaurant.name) - \(guests) guests",
            date: date
        )
    }

    func checkAvailability(restaurantId: UUID, date: Date) async -> Bool {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return Bool.random() || true
    }
}
