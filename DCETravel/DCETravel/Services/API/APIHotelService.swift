import Foundation

class APIHotelService: HotelServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchHotels(destination: String, checkIn: Date, checkOut: Date) async -> [Hotel] {
        let body = HotelSearchRequest(destination: destination, checkIn: checkIn, checkOut: checkOut, guests: nil)
        return (try? await client.post("/api/v1/hotels/search", body: body)) ?? []
    }

    func getHotelDetails(hotelId: UUID) async -> Hotel {
        if let hotel: Hotel = try? await client.get("/api/v1/hotels/\(hotelId)") {
            return hotel
        }
        return Hotel(id: hotelId, name: "Unknown", brand: "", starRating: 0, userRating: 0,
                    ratingCount: 0, location: "", locationDetail: "", pricePerNight: 0,
                    totalPrice: 0, pointsCost: 0, originalPointsCost: 0,
                    amenities: [], imageURLs: [], tier: nil, description: "")
    }

    func bookHotel(_ hotel: Hotel, guests: [String]) async -> Booking {
        struct BookBody: Encodable { let tripId: UUID?; let guests: [String] }
        return (try? await client.post("/api/v1/hotels/\(hotel.id)/book",
                                       body: BookBody(tripId: nil, guests: guests)))
            ?? Booking(id: UUID(), type: .hotel, status: .pending,
                      confirmationNumber: "ERR", tripId: UUID(),
                      details: "Booking failed", date: Date())
    }

    func applyPointsBoost(hotelId: UUID) async -> Hotel {
        if let hotel: Hotel = try? await client.post("/api/v1/hotels/\(hotelId)/points-boost") {
            return hotel
        }
        return await getHotelDetails(hotelId: hotelId)
    }
}
