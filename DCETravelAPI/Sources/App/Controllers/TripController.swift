import Vapor

struct TripController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let trips = routes.grouped("trips")
        trips.get(use: list)
        trips.post(use: create)
        trips.get(":id", use: getById)
        trips.put(":id", use: update)
        trips.post(":id", "itinerary", use: setItinerary)
        trips.get(":id", "bookings", use: bookings)
    }

    func list(req: Request) throws -> [Trip] {
        return DataStore.shared.trips
    }

    struct CreateTripRequest: Content {
        var name: String
        var destination: String
        var destinationCountry: String
        var startDate: Date
        var endDate: Date
        var travelers: [String]?
    }

    func create(req: Request) throws -> Response {
        let body = try req.content.decode(CreateTripRequest.self)

        let trip = Trip(
            id: UUID(), name: body.name, destination: body.destination,
            destinationCountry: body.destinationCountry,
            imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800",
            startDate: body.startDate, endDate: body.endDate,
            travelers: body.travelers ?? ["Victoria"],
            status: .planning, itinerary: nil, bookings: []
        )
        DataStore.shared.addTrip(trip)

        let response = Response(status: .created)
        try response.content.encode(trip)
        return response
    }

    func getById(req: Request) throws -> Trip {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid trip ID")
        }
        guard let trip = DataStore.shared.trips.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Trip not found")
        }
        return trip
    }

    struct UpdateTripRequest: Content {
        var name: String?
        var status: TripStatus?
        var travelers: [String]?
    }

    func update(req: Request) throws -> Trip {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid trip ID")
        }

        let body = try? req.content.decode(UpdateTripRequest.self)

        guard let trip = DataStore.shared.updateTrip(id: id, update: { t in
            if let name = body?.name { t.name = name }
            if let status = body?.status { t.status = status }
            if let travelers = body?.travelers { t.travelers = travelers }
        }) else {
            throw Abort(.notFound, reason: "Trip not found")
        }
        return trip
    }

    func setItinerary(req: Request) throws -> Trip {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid trip ID")
        }

        let itinerary = try req.content.decode(Itinerary.self)

        guard let trip = DataStore.shared.updateTrip(id: id, update: { t in
            t.itinerary = itinerary
        }) else {
            throw Abort(.notFound, reason: "Trip not found")
        }
        return trip
    }

    func bookings(req: Request) throws -> [Booking] {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid trip ID")
        }
        guard DataStore.shared.trips.contains(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Trip not found")
        }
        let tripBookings = DataStore.shared.bookings.filter { $0.tripId == id }
        return tripBookings
    }
}
