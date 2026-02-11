import Foundation

struct TripHandler {
    let dataStore: DataStore

    func list(_ request: HTTPRequest) -> HTTPResponse {
        return .json(dataStore.trips)
    }

    func create(_ request: HTTPRequest) -> HTTPResponse {
        struct CreateTripRequest: Codable {
            var name: String
            var destination: String
            var destinationCountry: String
            var startDate: Date
            var endDate: Date
            var travelers: [String]?
        }

        guard let body = request.jsonBody(CreateTripRequest.self) else {
            return .badRequest("Invalid trip data")
        }

        let trip = Trip(
            id: UUID(), name: body.name, destination: body.destination,
            destinationCountry: body.destinationCountry,
            imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800",
            startDate: body.startDate, endDate: body.endDate,
            travelers: body.travelers ?? ["Victoria"],
            status: .planning, itinerary: nil, bookings: []
        )
        dataStore.addTrip(trip)
        return .json(trip, status: 201)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid trip ID")
        }
        guard let trip = dataStore.trips.first(where: { $0.id == id }) else {
            return .notFound("Trip not found")
        }
        return .json(trip)
    }

    func update(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid trip ID")
        }

        struct UpdateTripRequest: Codable {
            var name: String?
            var status: TripStatus?
            var travelers: [String]?
        }
        let body = request.jsonBody(UpdateTripRequest.self)

        guard let trip = dataStore.updateTrip(id: id, update: { t in
            if let name = body?.name { t.name = name }
            if let status = body?.status { t.status = status }
            if let travelers = body?.travelers { t.travelers = travelers }
        }) else {
            return .notFound("Trip not found")
        }
        return .json(trip)
    }

    func setItinerary(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid trip ID")
        }

        guard let itinerary = request.jsonBody(Itinerary.self) else {
            return .badRequest("Invalid itinerary data")
        }

        guard let trip = dataStore.updateTrip(id: id, update: { t in
            t.itinerary = itinerary
        }) else {
            return .notFound("Trip not found")
        }
        return .json(trip)
    }

    func bookings(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 5,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid trip ID")
        }
        guard dataStore.trips.contains(where: { $0.id == id }) else {
            return .notFound("Trip not found")
        }
        let tripBookings = dataStore.bookings.filter { $0.tripId == id }
        return .json(tripBookings)
    }
}
