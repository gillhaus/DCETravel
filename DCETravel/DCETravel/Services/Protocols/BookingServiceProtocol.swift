import Foundation

protocol BookingServiceProtocol {
    func getBookings() async -> [Booking]
    func getBookings(tripId: UUID) async -> [Booking]
    func getTripBookings(tripId: UUID) async -> [Booking]
    func getBooking(id: UUID) async -> Booking?
    func cancelBooking(id: UUID) async -> Bool
    func modifyBooking(id: UUID, newDate: Date) async -> Booking
}
