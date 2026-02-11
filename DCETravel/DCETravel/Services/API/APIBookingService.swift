import Foundation

class APIBookingService: BookingServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func getBookings() async -> [Booking] {
        return (try? await client.get("/api/v1/bookings")) ?? []
    }

    func getBookings(tripId: UUID) async -> [Booking] {
        let items = [URLQueryItem(name: "tripId", value: tripId.uuidString)]
        return (try? await client.get("/api/v1/bookings", queryItems: items)) ?? []
    }

    func getTripBookings(tripId: UUID) async -> [Booking] {
        return (try? await client.get("/api/v1/trips/\(tripId)/bookings")) ?? []
    }

    func getBooking(id: UUID) async -> Booking? {
        return try? await client.get("/api/v1/bookings/\(id)")
    }

    func cancelBooking(id: UUID) async -> Bool {
        return (try? await client.delete("/api/v1/bookings/\(id)")) ?? false
    }

    func modifyBooking(id: UUID, newDate: Date) async -> Booking {
        struct ModifyBody: Encodable { let newDate: Date }
        return (try? await client.put("/api/v1/bookings/\(id)", body: ModifyBody(newDate: newDate)))
            ?? Booking(id: id, type: .hotel, status: .pending,
                      confirmationNumber: "ERR", tripId: UUID(),
                      details: "Modification failed", date: newDate)
    }
}
