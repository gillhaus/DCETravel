import Foundation

protocol RestaurantServiceProtocol {
    func searchRestaurants(location: String, cuisine: String?) async -> [Restaurant]
    func getRestaurant(id: UUID) async -> Restaurant?
    func bookTable(restaurantId: UUID, date: Date, guests: Int) async -> Booking
    func checkAvailability(restaurantId: UUID, date: Date) async -> Bool
}
