import Foundation

protocol HotelServiceProtocol {
    func searchHotels(destination: String, checkIn: Date, checkOut: Date) async -> [Hotel]
    func getHotelDetails(hotelId: UUID) async -> Hotel
    func bookHotel(_ hotel: Hotel, guests: [String]) async -> Booking
    func applyPointsBoost(hotelId: UUID) async -> Hotel
}
