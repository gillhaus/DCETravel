import Foundation

struct HotelSearchRequest: Codable {
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

struct HotelHandler {
    let dataStore: DataStore

    func search(_ request: HTTPRequest) -> HTTPResponse {
        let body = request.jsonBody(HotelSearchRequest.self)
        var results = dataStore.hotels

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

        return .json(results)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid hotel ID")
        }
        guard let hotel = dataStore.hotels.first(where: { $0.id == id }) else {
            return .notFound("Hotel not found")
        }
        return .json(hotel)
    }

    func book(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let hotelId = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid hotel ID")
        }
        guard let hotel = dataStore.hotels.first(where: { $0.id == hotelId }) else {
            return .notFound("Hotel not found")
        }

        struct BookRequest: Codable {
            var tripId: UUID?
            var guests: [String]?
            var usePoints: Bool?
            var checkIn: Date?
            var checkOut: Date?
        }
        let body = request.jsonBody(BookRequest.self)
        let tripId = body?.tripId ?? (dataStore.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = hotel.totalPrice
        if usePoints {
            pointsUsed = hotel.pointsCost
            price = nil
            dataStore.updateUser { $0.pointsBalance -= hotel.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .hotel, status: .confirmed,
            confirmationNumber: dataStore.generateConfirmationNumber(prefix: "HT"),
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
        dataStore.addBooking(booking)
        return .json(booking, status: 201)
    }

    func pointsBoost(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let hotelId = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid hotel ID")
        }
        guard let hotel = dataStore.updateHotel(id: hotelId, update: { h in
            h.pointsCost = Int(Double(h.originalPointsCost) * 0.67)
        }) else {
            return .notFound("Hotel not found")
        }
        return .json(hotel)
    }
}
