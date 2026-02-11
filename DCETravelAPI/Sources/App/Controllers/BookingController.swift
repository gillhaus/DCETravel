import Vapor

struct BookingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bookings = routes.grouped("bookings")
        bookings.get(use: list)
        bookings.get(":id", use: getById)
        bookings.put(":id", use: modify)
        bookings.delete(":id", use: cancel)
    }

    func list(req: Request) throws -> [Booking] {
        var results = DataStore.shared.bookings

        // Filter by tripId
        if let tripIdStr: String = req.query["tripId"],
           let tripId = UUID(uuidString: tripIdStr) {
            results = results.filter { $0.tripId == tripId }
        }

        // Filter by type
        if let typeStr: String = req.query["type"] {
            results = results.filter { $0.type.rawValue.lowercased() == typeStr.lowercased() }
        }

        // Filter by status
        if let statusStr: String = req.query["status"] {
            results = results.filter { $0.status.rawValue.lowercased() == statusStr.lowercased() }
        }

        return results
    }

    func getById(req: Request) throws -> Booking {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid booking ID")
        }
        guard let booking = DataStore.shared.bookings.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Booking not found")
        }
        return booking
    }

    struct ModifyRequest: Content {
        var newDate: Date?
        var details: String?
    }

    func modify(req: Request) throws -> Booking {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid booking ID")
        }

        let body = try? req.content.decode(ModifyRequest.self)

        guard let booking = DataStore.shared.updateBooking(id: id, update: { b in
            if let newDate = body?.newDate { b.date = newDate }
            if let details = body?.details { b.details = details }
        }) else {
            throw Abort(.notFound, reason: "Booking not found")
        }
        return booking
    }

    struct CancelResponse: Content {
        let success: Bool
        let message: String
        let pointsRefunded: Int?
    }

    func cancel(req: Request) throws -> CancelResponse {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid booking ID")
        }

        // Find booking first to refund points
        guard let booking = DataStore.shared.bookings.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Booking not found")
        }

        // Refund points if any were used
        if let pointsUsed = booking.pointsUsed, pointsUsed > 0 {
            DataStore.shared.updateUser { $0.pointsBalance += pointsUsed }
        }

        guard let _ = DataStore.shared.updateBooking(id: id, update: { b in
            b.status = .cancelled
        }) else {
            throw Abort(.notFound, reason: "Booking not found")
        }

        return CancelResponse(
            success: true,
            message: "Booking cancelled",
            pointsRefunded: booking.pointsUsed
        )
    }
}
