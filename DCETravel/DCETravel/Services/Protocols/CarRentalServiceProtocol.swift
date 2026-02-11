import Foundation

protocol CarRentalServiceProtocol {
    func searchCars(location: String, pickupDate: Date, dropoffDate: Date) async -> [CarRental]
    func getCarDetails(carId: UUID) async -> CarRental?
    func bookCar(_ car: CarRental) async -> Booking
}
