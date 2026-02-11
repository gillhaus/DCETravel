import Vapor

struct RestaurantController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let restaurants = routes.grouped("restaurants")
        restaurants.post("search", use: search)
        restaurants.get(":id", use: getById)
        restaurants.get(":id", "availability", use: availability)
        restaurants.post(":id", "reserve", use: reserve)
    }

    struct RestaurantSearchRequest: Content {
        var location: String?
        var cuisine: String?
        var priceLevel: String?
        var minRating: Double?
        var sort: String?
    }

    func search(req: Request) throws -> [Restaurant] {
        let body = try? req.content.decode(RestaurantSearchRequest.self)
        var results = DataStore.shared.restaurants

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

        return results
    }

    func getById(req: Request) throws -> Restaurant {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid restaurant ID")
        }
        guard let restaurant = DataStore.shared.restaurants.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Restaurant not found")
        }
        return restaurant
    }

    struct AvailabilityResponse: Content {
        let available: Bool
        let nextAvailableTime: String?
    }

    func availability(req: Request) throws -> AvailabilityResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid restaurant ID")
        }
        guard let restaurant = DataStore.shared.restaurants.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Restaurant not found")
        }

        let isAvailable = !restaurant.isBooked
        return AvailabilityResponse(
            available: isAvailable,
            nextAvailableTime: isAvailable ? nil : "9:00 PM"
        )
    }

    struct ReserveRequest: Content {
        var date: Date?
        var guests: Int?
        var tripId: UUID?
        var usePoints: Bool?
    }

    func reserve(req: Request) throws -> Response {
        guard let restaurantId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid restaurant ID")
        }
        guard let restaurant = DataStore.shared.restaurants.first(where: { $0.id == restaurantId }) else {
            throw Abort(.notFound, reason: "Restaurant not found")
        }

        let body = try? req.content.decode(ReserveRequest.self)
        let tripId = body?.tripId ?? (DataStore.shared.trips.first?.id ?? UUID())
        let guests = body?.guests ?? 2

        // Mark restaurant as booked
        _ = DataStore.shared.updateRestaurant(id: restaurantId) { r in
            r.isBooked = true
            r.reservationDate = body?.date
            r.guestCount = guests
        }

        let booking = Booking(
            id: UUID(), type: .restaurant, status: .confirmed,
            confirmationNumber: DataStore.shared.generateConfirmationNumber(prefix: "RS"),
            tripId: tripId,
            details: "\(restaurant.name) - \(guests) guests",
            date: body?.date ?? Date(),
            sourceId: restaurant.id,
            guestCount: guests
        )
        DataStore.shared.addBooking(booking)

        let response = Response(status: .created)
        try response.content.encode(booking)
        return response
    }
}
