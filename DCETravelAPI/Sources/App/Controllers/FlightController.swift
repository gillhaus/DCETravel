import Vapor

struct FlightController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let flights = routes.grouped("flights")
        flights.post("search", use: search)
        flights.get(":id", use: getById)
        flights.post(":id", "book", use: book)
        flights.get(":id", "status", use: status)
    }

    struct FlightSearchRequest: Content {
        var origin: String?
        var destination: String?
        var date: Date?
        var passengers: Int?
        var cabinClass: String?
        var airline: String?
        var minPrice: Double?
        var maxPrice: Double?
        var sort: String?
    }

    func search(req: Request) throws -> [Flight] {
        let body = try? req.content.decode(FlightSearchRequest.self)
        var results = DataStore.shared.flights

        if let origin = body?.origin?.uppercased(), !origin.isEmpty {
            results = results.filter { $0.departureAirport.uppercased().contains(origin) }
        }
        if let dest = body?.destination?.uppercased(), !dest.isEmpty {
            results = results.filter { $0.arrivalAirport.uppercased().contains(dest) }
        }
        if let cabinClass = body?.cabinClass?.lowercased() {
            results = results.filter { $0.cabinClass.rawValue.lowercased() == cabinClass }
        }
        if let airline = body?.airline?.lowercased(), !airline.isEmpty {
            results = results.filter { $0.airline.lowercased().contains(airline) }
        }
        if let minPrice = body?.minPrice {
            results = results.filter { $0.price >= minPrice }
        }
        if let maxPrice = body?.maxPrice {
            results = results.filter { $0.price <= maxPrice }
        }

        // Sort
        if let sort = body?.sort?.lowercased() {
            switch sort {
            case "price_asc": results.sort { $0.price < $1.price }
            case "price_desc": results.sort { $0.price > $1.price }
            case "departure": results.sort { $0.departureTime < $1.departureTime }
            case "points": results.sort { $0.pointsCost < $1.pointsCost }
            default: break
            }
        }

        return results
    }

    func getById(req: Request) throws -> Flight {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        guard let flight = DataStore.shared.flights.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Flight not found")
        }
        return flight
    }

    struct BookRequest: Content {
        var tripId: UUID?
        var usePoints: Bool?
        var passengers: [String]?
    }

    func book(req: Request) throws -> Response {
        guard let flightId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        guard let flight = DataStore.shared.flights.first(where: { $0.id == flightId }) else {
            throw Abort(.notFound, reason: "Flight not found")
        }

        let body = try? req.content.decode(BookRequest.self)
        let tripId = body?.tripId ?? (DataStore.shared.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = flight.price
        if usePoints {
            pointsUsed = flight.pointsCost
            price = nil
            DataStore.shared.updateUser { $0.pointsBalance -= flight.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .flight, status: .confirmed,
            confirmationNumber: DataStore.shared.generateConfirmationNumber(prefix: "FL"),
            tripId: tripId,
            details: "\(flight.airline) \(flight.flightNumber) - \(flight.departureAirport) to \(flight.arrivalAirport)",
            date: flight.departureTime,
            sourceId: flight.id,
            price: price,
            pointsUsed: pointsUsed,
            passengers: body?.passengers
        )
        DataStore.shared.addBooking(booking)

        let response = Response(status: .created)
        try response.content.encode(booking)
        return response
    }

    struct FlightStatusResponse: Content {
        let flightNumber: String
        let status: Flight.FlightStatus
        let departureTime: Date
        let arrivalTime: Date
    }

    func status(req: Request) throws -> FlightStatusResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid flight ID")
        }
        guard let flight = DataStore.shared.flights.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Flight not found")
        }

        return FlightStatusResponse(
            flightNumber: flight.flightNumber,
            status: flight.status,
            departureTime: flight.departureTime,
            arrivalTime: flight.arrivalTime
        )
    }
}
