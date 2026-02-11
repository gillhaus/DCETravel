import Foundation

class MockHotelService: HotelServiceProtocol {
    func searchHotels(destination: String, checkIn: Date, checkOut: Date) async -> [Hotel] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
        return MockData.hotels
    }

    func getHotelDetails(hotelId: UUID) async -> Hotel {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return MockData.hotels.first { $0.id == hotelId } ?? MockData.hotels[0]
    }

    func bookHotel(_ hotel: Hotel, guests: [String]) async -> Booking {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        return Booking(
            id: UUID(),
            type: .hotel,
            status: .confirmed,
            confirmationNumber: "HT\(Int.random(in: 100000...999999))",
            tripId: UUID(),
            details: "\(hotel.name) - \(guests.count) guests",
            date: Date()
        )
    }

    func applyPointsBoost(hotelId: UUID) async -> Hotel {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        var hotel = MockData.hotels.first { $0.id == hotelId } ?? MockData.hotels[0]
        hotel = Hotel(
            id: hotel.id, name: hotel.name, brand: hotel.brand,
            starRating: hotel.starRating, userRating: hotel.userRating,
            ratingCount: hotel.ratingCount, location: hotel.location,
            locationDetail: hotel.locationDetail, pricePerNight: hotel.pricePerNight,
            totalPrice: hotel.totalPrice,
            pointsCost: Int(Double(hotel.pointsCost) * 0.667),
            originalPointsCost: hotel.pointsCost,
            amenities: hotel.amenities, imageURLs: hotel.imageURLs,
            tier: hotel.tier, description: hotel.description
        )
        return hotel
    }
}
