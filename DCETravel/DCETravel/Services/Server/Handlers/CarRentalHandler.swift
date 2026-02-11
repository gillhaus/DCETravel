import Foundation

struct CarRentalSearchRequest: Codable {
    var location: String?
    var pickupDate: Date?
    var dropoffDate: Date?
    var carType: String?
    var company: String?
    var minPrice: Double?
    var maxPrice: Double?
    var sort: String?
}

struct CarRentalHandler {
    let dataStore: DataStore

    func search(_ request: HTTPRequest) -> HTTPResponse {
        let body = request.jsonBody(CarRentalSearchRequest.self)
        var results = dataStore.carRentals

        if let location = body?.location?.lowercased(), !location.isEmpty {
            results = results.filter {
                $0.pickupLocation.lowercased().contains(location) ||
                $0.dropoffLocation.lowercased().contains(location)
            }
        }
        if let carType = body?.carType?.lowercased(), !carType.isEmpty {
            results = results.filter { $0.carType.rawValue.lowercased() == carType }
        }
        if let company = body?.company?.lowercased(), !company.isEmpty {
            results = results.filter { $0.company.lowercased().contains(company) }
        }
        if let minPrice = body?.minPrice {
            results = results.filter { $0.pricePerDay >= minPrice }
        }
        if let maxPrice = body?.maxPrice {
            results = results.filter { $0.pricePerDay <= maxPrice }
        }

        // Recalculate totalPrice based on actual day count
        if let pickup = body?.pickupDate, let dropoff = body?.dropoffDate {
            let days = max(1, Calendar.current.dateComponents([.day], from: pickup, to: dropoff).day ?? 1)
            results = results.map { car in
                var c = car
                c.totalPrice = c.pricePerDay * Double(days)
                return c
            }
        }

        // Sort
        if let sort = body?.sort?.lowercased() {
            switch sort {
            case "price_asc": results.sort { $0.pricePerDay < $1.pricePerDay }
            case "price_desc": results.sort { $0.pricePerDay > $1.pricePerDay }
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
            return .badRequest("Invalid car rental ID")
        }
        guard let car = dataStore.carRentals.first(where: { $0.id == id }) else {
            return .notFound("Car rental not found")
        }
        return .json(car)
    }

    func book(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let carId = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid car rental ID")
        }
        guard let car = dataStore.carRentals.first(where: { $0.id == carId }) else {
            return .notFound("Car rental not found")
        }

        struct BookRequest: Codable {
            var tripId: UUID?
            var usePoints: Bool?
        }
        let body = request.jsonBody(BookRequest.self)
        let tripId = body?.tripId ?? (dataStore.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = car.totalPrice
        if usePoints {
            pointsUsed = car.pointsCost
            price = nil
            dataStore.updateUser { $0.pointsBalance -= car.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .carRental, status: .confirmed,
            confirmationNumber: dataStore.generateConfirmationNumber(prefix: "CR"),
            tripId: tripId,
            details: "\(car.company) \(car.carType.rawValue) - \(car.model)",
            date: Date(),
            sourceId: car.id,
            price: price,
            pointsUsed: pointsUsed
        )
        dataStore.addBooking(booking)
        return .json(booking, status: 201)
    }
}
