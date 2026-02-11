import Foundation

struct BookingHandler {
    let dataStore: DataStore

    func list(_ request: HTTPRequest) -> HTTPResponse {
        var results = dataStore.bookings

        // Filter by tripId
        if let tripIdStr = request.queryParameters["tripId"],
           let tripId = UUID(uuidString: tripIdStr) {
            results = results.filter { $0.tripId == tripId }
        }

        // Filter by type
        if let typeStr = request.queryParameters["type"] {
            results = results.filter { $0.type.rawValue.lowercased() == typeStr.lowercased() }
        }

        // Filter by status
        if let statusStr = request.queryParameters["status"] {
            results = results.filter { $0.status.rawValue.lowercased() == statusStr.lowercased() }
        }

        return .json(results)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid booking ID")
        }
        guard let booking = dataStore.bookings.first(where: { $0.id == id }) else {
            return .notFound("Booking not found")
        }
        return .json(booking)
    }

    func modify(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid booking ID")
        }

        struct ModifyRequest: Codable {
            var newDate: Date?
            var details: String?
        }
        let body = request.jsonBody(ModifyRequest.self)

        guard let booking = dataStore.updateBooking(id: id, update: { b in
            if let newDate = body?.newDate { b.date = newDate }
            if let details = body?.details { b.details = details }
        }) else {
            return .notFound("Booking not found")
        }
        return .json(booking)
    }

    func cancel(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard components.count >= 4,
              let id = UUID(uuidString: components[3]) else {
            return .badRequest("Invalid booking ID")
        }

        // Find booking first to refund points
        guard let booking = dataStore.bookings.first(where: { $0.id == id }) else {
            return .notFound("Booking not found")
        }

        // Refund points if any were used
        if let pointsUsed = booking.pointsUsed, pointsUsed > 0 {
            dataStore.updateUser { $0.pointsBalance += pointsUsed }
        }

        guard let _ = dataStore.updateBooking(id: id, update: { b in
            b.status = .cancelled
        }) else {
            return .notFound("Booking not found")
        }

        struct CancelResponse: Codable { let success: Bool; let message: String; let pointsRefunded: Int? }
        return .json(CancelResponse(
            success: true,
            message: "Booking cancelled",
            pointsRefunded: booking.pointsUsed
        ))
    }
}
