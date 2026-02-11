import Foundation

class APICarRentalService: CarRentalServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchCars(location: String, pickupDate: Date, dropoffDate: Date) async -> [CarRental] {
        let body = CarRentalSearchRequest(location: location, pickupDate: pickupDate, dropoffDate: dropoffDate)
        return (try? await client.post("/api/v1/cars/search", body: body)) ?? []
    }

    func getCarDetails(carId: UUID) async -> CarRental? {
        return try? await client.get("/api/v1/cars/\(carId)")
    }

    func bookCar(_ car: CarRental) async -> Booking {
        struct BookBody: Encodable { let tripId: UUID? }
        return (try? await client.post("/api/v1/cars/\(car.id)/book", body: BookBody(tripId: nil)))
            ?? Booking(id: UUID(), type: .carRental, status: .pending,
                      confirmationNumber: "ERR", tripId: UUID(),
                      details: "Booking failed", date: Date())
    }
}
