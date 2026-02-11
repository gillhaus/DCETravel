import Foundation

struct FlightSearchRequest: Codable {
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

struct FlightHandler {
    let dataStore: DataStore

    func search(_ request: HTTPRequest) -> HTTPResponse {
        let body = request.jsonBody(FlightSearchRequest.self)
        var results = dataStore.flights

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

        return .json(results)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid flight ID")
        }
        guard let flight = dataStore.flights.first(where: { $0.id == id }) else {
            return .notFound("Flight not found")
        }
        return .json(flight)
    }

    func book(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let flightId = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid flight ID")
        }
        guard let flight = dataStore.flights.first(where: { $0.id == flightId }) else {
            return .notFound("Flight not found")
        }

        struct BookRequest: Codable {
            var tripId: UUID?
            var usePoints: Bool?
            var passengers: [String]?
        }
        let body = request.jsonBody(BookRequest.self)
        let tripId = body?.tripId ?? (dataStore.trips.first?.id ?? UUID())
        let usePoints = body?.usePoints ?? false

        var pointsUsed: Int? = nil
        var price: Double? = flight.price
        if usePoints {
            pointsUsed = flight.pointsCost
            price = nil
            dataStore.updateUser { $0.pointsBalance -= flight.pointsCost }
        }

        let booking = Booking(
            id: UUID(), type: .flight, status: .confirmed,
            confirmationNumber: dataStore.generateConfirmationNumber(prefix: "FL"),
            tripId: tripId,
            details: "\(flight.airline) \(flight.flightNumber) - \(flight.departureAirport) to \(flight.arrivalAirport)",
            date: flight.departureTime,
            sourceId: flight.id,
            price: price,
            pointsUsed: pointsUsed,
            passengers: body?.passengers
        )
        dataStore.addBooking(booking)
        return .json(booking, status: 201)
    }

    func status(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid flight ID")
        }
        guard let flight = dataStore.flights.first(where: { $0.id == id }) else {
            return .notFound("Flight not found")
        }

        struct FlightStatusResponse: Codable {
            let flightNumber: String
            let status: Flight.FlightStatus
            let departureTime: Date
            let arrivalTime: Date
        }

        let response = FlightStatusResponse(
            flightNumber: flight.flightNumber,
            status: flight.status,
            departureTime: flight.departureTime,
            arrivalTime: flight.arrivalTime
        )
        return .json(response)
    }
}
