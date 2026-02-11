import Foundation

class APIRestaurantService: RestaurantServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchRestaurants(location: String, cuisine: String?) async -> [Restaurant] {
        let body = RestaurantSearchRequest(location: location, cuisine: cuisine)
        return (try? await client.post("/api/v1/restaurants/search", body: body)) ?? []
    }

    func getRestaurant(id: UUID) async -> Restaurant? {
        return try? await client.get("/api/v1/restaurants/\(id)")
    }

    func bookTable(restaurantId: UUID, date: Date, guests: Int) async -> Booking {
        struct ReserveBody: Encodable {
            let date: Date
            let guests: Int
            let tripId: UUID?
        }
        return (try? await client.post("/api/v1/restaurants/\(restaurantId)/reserve",
                                       body: ReserveBody(date: date, guests: guests, tripId: nil)))
            ?? Booking(id: UUID(), type: .restaurant, status: .pending,
                      confirmationNumber: "ERR", tripId: UUID(),
                      details: "Reservation failed", date: Date())
    }

    func checkAvailability(restaurantId: UUID, date: Date) async -> Bool {
        struct AvailResponse: Decodable { let available: Bool }
        let items = [URLQueryItem(name: "date", value: ISO8601DateFormatter().string(from: date)),
                     URLQueryItem(name: "guests", value: "2")]
        let response: AvailResponse? = try? await client.get(
            "/api/v1/restaurants/\(restaurantId)/availability", queryItems: items)
        return response?.available ?? true
    }
}
