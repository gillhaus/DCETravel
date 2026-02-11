import Foundation

class MockFlightService: FlightServiceProtocol {
    func searchFlights(from: String, to: String, date: Date) async -> [Flight] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
        return MockData.flights
    }

    func bookFlight(_ flight: Flight) async -> Booking {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        return Booking(
            id: UUID(),
            type: .flight,
            status: .confirmed,
            confirmationNumber: "FL\(Int.random(in: 100000...999999))",
            tripId: UUID(),
            details: "\(flight.airline) \(flight.flightNumber) - \(flight.departureAirport) to \(flight.arrivalAirport)",
            date: flight.departureTime
        )
    }

    func getFlightStatus(flightId: UUID) async -> Flight {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return MockData.flights[0]
    }
}
