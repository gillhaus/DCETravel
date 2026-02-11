import Vapor

struct CarRentalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let cars = routes.grouped("cars")
        cars.post("search", use: search)
        cars.get(":id", use: getById)
        cars.post(":id", "book", use: book)
    }

    struct CarRentalSearchRequest: Content {
        var location: String?
        var pickupDate: Date?
        var dropoffDate: Date?
        var carType: String?
        var company: String?
        var minPrice: Double?
        var maxPrice: Double?
        var sort: String?
    }

    func search(req: Request) throws -> [CarRental] {
        let body = try? req.content.decode(CarRentalSearchRequest.self)
        var results = DataStore.shared.carRentals

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

        return results
    }

    func getById(req: Request) throws -> CarRental {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid car rental ID")
        }
        guard let car = DataStore.shared.carRentals.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Car rental not found")
        }
        return car
    }

    struct BookRequest: Content {
        var tripId: UUID?
        var usePoints: Bool?
    }

    func book(req: Request) throws -> Response {
        guard let carId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid car rental ID")
        }
        guard let car = DataStore.shared.carRentals.first(where: { $0.id == carId }) else {
            throw Abort(.notFound, reason: "Car rental not found")
        }

        let body = try? req.content.decode(BookRequest.self)
        let tripId = body?.tripId ?? (DataStore.shared.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = car.totalPrice
        if usePoints {
            pointsUsed = car.pointsCost
            price = nil
            DataStore.shared.updateUser { $0.pointsBalance -= car.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .carRental, status: .confirmed,
            confirmationNumber: DataStore.shared.generateConfirmationNumber(prefix: "CR"),
            tripId: tripId,
            details: "\(car.company) \(car.carType.rawValue) - \(car.model)",
            date: Date(),
            sourceId: car.id,
            price: price,
            pointsUsed: pointsUsed
        )
        DataStore.shared.addBooking(booking)

        let response = Response(status: .created)
        try response.content.encode(booking)
        return response
    }
}
