import Foundation

protocol FlightServiceProtocol {
    func searchFlights(from: String, to: String, date: Date) async -> [Flight]
    func bookFlight(_ flight: Flight) async -> Booking
    func getFlightStatus(flightId: UUID) async -> Flight
}
