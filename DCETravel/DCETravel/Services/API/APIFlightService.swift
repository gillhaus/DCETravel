import Foundation

class APIFlightService: FlightServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchFlights(from origin: String, to destination: String, date: Date) async -> [Flight] {
        let body = FlightSearchRequest(
            origin: origin, destination: destination, date: date,
            passengers: nil, cabinClass: nil
        )
        return (try? await client.post("/api/v1/flights/search", body: body)) ?? []
    }

    func bookFlight(_ flight: Flight) async -> Booking {
        struct BookBody: Encodable { let tripId: UUID? }
        return (try? await client.post("/api/v1/flights/\(flight.id)/book", body: BookBody(tripId: nil)))
            ?? Booking(id: UUID(), type: .flight, status: .pending,
                      confirmationNumber: "ERR", tripId: UUID(),
                      details: "Booking failed", date: Date())
    }

    func getFlightStatus(flightId: UUID) async -> Flight {
        if let flight: Flight = try? await client.get("/api/v1/flights/\(flightId)") {
            return flight
        }
        return Flight(id: flightId, airline: "Unknown", flightNumber: "N/A",
                     departureAirport: "---", arrivalAirport: "---",
                     departureTime: Date(), arrivalTime: Date(),
                     price: 0, pointsCost: 0, cabinClass: .economy, status: .cancelled)
    }
}
