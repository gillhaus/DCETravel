import Vapor

struct HotelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let hotels = routes.grouped("hotels")
        hotels.post("search", use: search)
        hotels.get(":id", use: getById)
        hotels.post(":id", "book", use: book)
        hotels.post(":id", "points-boost", use: pointsBoost)
    }

    struct HotelSearchRequest: Content {
        var destination: String?
        var checkIn: Date?
        var checkOut: Date?
        var guests: Int?
        var minPrice: Double?
        var maxPrice: Double?
        var starRating: Int?
        var tier: String?
        var sort: String?
    }

    func search(req: Request) throws -> [Hotel] {
        let body = try? req.content.decode(HotelSearchRequest.self)
        var results = DataStore.shared.hotels

        if let destination = body?.destination?.lowercased(), !destination.isEmpty {
            results = results.filter {
                $0.location.lowercased().contains(destination) ||
                $0.name.lowercased().contains(destination)
            }
        }
        if let minPrice = body?.minPrice {
            results = results.filter { $0.pricePerNight >= minPrice }
        }
        if let maxPrice = body?.maxPrice {
            results = results.filter { $0.pricePerNight <= maxPrice }
        }
        if let starRating = body?.starRating {
            results = results.filter { $0.starRating >= starRating }
        }
        if let tier = body?.tier?.lowercased(), !tier.isEmpty {
            results = results.filter { $0.tier?.rawValue.lowercased() == tier }
        }

        // Recalculate totalPrice based on actual night count
        if let checkIn = body?.checkIn, let checkOut = body?.checkOut {
            let nights = max(1, Calendar.current.dateComponents([.day], from: checkIn, to: checkOut).day ?? 1)
            results = results.map { hotel in
                var h = hotel
                h.totalPrice = h.pricePerNight * Double(nights)
                return h
            }
        }

        // Sort
        if let sort = body?.sort?.lowercased() {
            switch sort {
            case "price_asc": results.sort { $0.pricePerNight < $1.pricePerNight }
            case "price_desc": results.sort { $0.pricePerNight > $1.pricePerNight }
            case "rating": results.sort { $0.userRating > $1.userRating }
            case "stars": results.sort { $0.starRating > $1.starRating }
            case "points": results.sort { $0.pointsCost < $1.pointsCost }
            default: break
            }
        }

        return results
    }

    func getById(req: Request) throws -> Hotel {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid hotel ID")
        }
        guard let hotel = DataStore.shared.hotels.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Hotel not found")
        }
        return hotel
    }

    struct BookRequest: Content {
        var tripId: UUID?
        var guests: [String]?
        var usePoints: Bool?
        var checkIn: Date?
        var checkOut: Date?
    }

    func book(req: Request) throws -> Response {
        guard let hotelId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid hotel ID")
        }
        guard let hotel = DataStore.shared.hotels.first(where: { $0.id == hotelId }) else {
            throw Abort(.notFound, reason: "Hotel not found")
        }

        let body = try? req.content.decode(BookRequest.self)
        let tripId = body?.tripId ?? (DataStore.shared.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = hotel.totalPrice
        if usePoints {
            pointsUsed = hotel.pointsCost
            price = nil
            DataStore.shared.updateUser { $0.pointsBalance -= hotel.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .hotel, status: .confirmed,
            confirmationNumber: DataStore.shared.generateConfirmationNumber(prefix: "HT"),
            tripId: tripId,
            details: "\(hotel.name) - \(hotel.location)",
            date: body?.checkIn ?? Date(),
            sourceId: hotel.id,
            price: price,
            pointsUsed: pointsUsed,
            checkInDate: body?.checkIn,
            checkOutDate: body?.checkOut,
            guestCount: body?.guests?.count
        )
        DataStore.shared.addBooking(booking)

        let response = Response(status: .created)
        try response.content.encode(booking)
        return response
    }

    func pointsBoost(req: Request) throws -> Hotel {
        guard let hotelId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid hotel ID")
        }
        guard let hotel = DataStore.shared.updateHotel(id: hotelId, update: { h in
            h.pointsCost = Int(Double(h.originalPointsCost) * 0.67)
        }) else {
            throw Abort(.notFound, reason: "Hotel not found")
        }
        return hotel
    }
}
