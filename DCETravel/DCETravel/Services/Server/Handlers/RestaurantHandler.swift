import Foundation

struct RestaurantSearchRequest: Codable {
    var location: String?
    var cuisine: String?
    var priceLevel: String?
    var minRating: Double?
    var sort: String?
}

struct RestaurantHandler {
    let dataStore: DataStore

    func search(_ request: HTTPRequest) -> HTTPResponse {
        let body = request.jsonBody(RestaurantSearchRequest.self)
        var results = dataStore.restaurants

        if let location = body?.location?.lowercased(), !location.isEmpty {
            results = results.filter { $0.location.lowercased().contains(location) }
        }
        if let cuisine = body?.cuisine?.lowercased(), !cuisine.isEmpty {
            results = results.filter { $0.cuisine.lowercased().contains(cuisine) }
        }
        if let priceLevel = body?.priceLevel, !priceLevel.isEmpty {
            results = results.filter { $0.priceLevel == priceLevel }
        }
        if let minRating = body?.minRating {
            results = results.filter { $0.rating >= minRating }
        }

        // Sort
        if let sort = body?.sort?.lowercased() {
            switch sort {
            case "rating": results.sort { $0.rating > $1.rating }
            case "price_asc":
                results.sort { $0.priceLevel.count < $1.priceLevel.count }
            case "price_desc":
                results.sort { $0.priceLevel.count > $1.priceLevel.count }
            default: break
            }
        }

        return .json(results)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid restaurant ID")
        }
        guard let restaurant = dataStore.restaurants.first(where: { $0.id == id }) else {
            return .notFound("Restaurant not found")
        }
        return .json(restaurant)
    }

    func availability(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid restaurant ID")
        }
        guard dataStore.restaurants.contains(where: { $0.id == id }) else {
            return .notFound("Restaurant not found")
        }

        struct AvailabilityResponse: Codable {
            let available: Bool
            let nextAvailableTime: String?
        }

        let restaurant = dataStore.restaurants.first { $0.id == id }!
        let isAvailable = !restaurant.isBooked
        return .json(AvailabilityResponse(
            available: isAvailable,
            nextAvailableTime: isAvailable ? nil : "9:00 PM"
        ))
    }

    func reserve(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let restaurantId = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid restaurant ID")
        }
        guard let restaurant = dataStore.restaurants.first(where: { $0.id == restaurantId }) else {
            return .notFound("Restaurant not found")
        }

        struct ReserveRequest: Codable {
            var date: Date?
            var guests: Int?
            var tripId: UUID?
            var usePoints: Bool?
        }
        let body = request.jsonBody(ReserveRequest.self)
        let tripId = body?.tripId ?? (dataStore.trips.first?.id ?? UUID())
        let guests = body?.guests ?? 2

        // Mark restaurant as booked
        _ = dataStore.updateRestaurant(id: restaurantId) { r in
            r.isBooked = true
            r.reservationDate = body?.date
            r.guestCount = guests
        }

        let booking = Booking(
            id: UUID(), type: .restaurant, status: .confirmed,
            confirmationNumber: dataStore.generateConfirmationNumber(prefix: "RS"),
            tripId: tripId,
            details: "\(restaurant.name) - \(guests) guests",
            date: body?.date ?? Date(),
            sourceId: restaurant.id,
            guestCount: guests
        )
        dataStore.addBooking(booking)
        return .json(booking, status: 201)
    }
}
