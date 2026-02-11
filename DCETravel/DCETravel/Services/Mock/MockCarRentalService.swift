import Foundation

class MockCarRentalService: CarRentalServiceProtocol {
    func searchCars(location: String, pickupDate: Date, dropoffDate: Date) async -> [CarRental] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_500_000_000))
        return [
            CarRental(id: UUID(), company: "Hertz", carType: .economy,
                     model: "Toyota Corolla", pricePerDay: 45, totalPrice: 270,
                     pointsCost: 12_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "", features: ["Automatic", "GPS"], seating: 5)
        ]
    }

    func getCarDetails(carId: UUID) async -> CarRental? {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return nil
    }

    func bookCar(_ car: CarRental) async -> Booking {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        return Booking(
            id: UUID(), type: .carRental, status: .confirmed,
            confirmationNumber: "CR\(Int.random(in: 100000...999999))",
            tripId: UUID(),
            details: "\(car.company) \(car.carType.rawValue) - \(car.model)",
            date: Date()
        )
    }
}
