import Foundation

class MockBookingService: BookingServiceProtocol {
    private var bookings: [Booking] = MockData.bookings

    func getBookings() async -> [Booking] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        return bookings
    }

    func getBookings(tripId: UUID) async -> [Booking] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return bookings.filter { $0.tripId == tripId }
    }

    func getTripBookings(tripId: UUID) async -> [Booking] {
        return await getBookings(tripId: tripId)
    }

    func getBooking(id: UUID) async -> Booking? {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return bookings.first { $0.id == id }
    }

    func cancelBooking(id: UUID) async -> Bool {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].status = .cancelled
            return true
        }
        return false
    }

    func modifyBooking(id: UUID, newDate: Date) async -> Booking {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].date = newDate
            return bookings[index]
        }
        return bookings[0]
    }
}
