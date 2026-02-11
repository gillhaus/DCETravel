import Foundation

@MainActor
class TripSuggestionsViewModel: ObservableObject {
    @Published var destinations: [Destination] = []
    @Published var selectedDestination: Destination?
    @Published var flights: [Flight] = []
    @Published var hotels: [Hotel] = []
    @Published var carRentals: [CarRental] = []
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false

    func loadDestinations(services: ServiceContainer) async {
        let results = await services.travel.getInspiration()
        destinations = results
        if selectedDestination == nil, let first = results.first {
            selectedDestination = first
            await loadForDestination(first, services: services)
        }
    }

    func selectDestination(_ destination: Destination, services: ServiceContainer) async {
        selectedDestination = destination
        await loadForDestination(destination, services: services)
    }

    func loadForDestination(_ destination: Destination, services: ServiceContainer) async {
        isLoading = true
        defer { isLoading = false }

        let location = destination.name
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now

        async let fetchFlights = services.flights.searchFlights(from: "", to: location, date: now)
        async let fetchHotels = services.hotels.searchHotels(destination: location, checkIn: now, checkOut: weekFromNow)
        async let fetchCars = services.carRentals.searchCars(location: location, pickupDate: now, dropoffDate: weekFromNow)
        async let fetchRestaurants = services.restaurants.searchRestaurants(location: location, cuisine: nil)

        flights = await fetchFlights
        hotels = await fetchHotels
        carRentals = await fetchCars
        restaurants = await fetchRestaurants
    }

    func loadForTrip(_ trip: Trip, services: ServiceContainer) async {
        isLoading = true
        defer { isLoading = false }

        let location = trip.destination

        async let fetchFlights = services.flights.searchFlights(from: "", to: location, date: trip.startDate)
        async let fetchHotels = services.hotels.searchHotels(destination: location, checkIn: trip.startDate, checkOut: trip.endDate)
        async let fetchCars = services.carRentals.searchCars(location: location, pickupDate: trip.startDate, dropoffDate: trip.endDate)
        async let fetchRestaurants = services.restaurants.searchRestaurants(location: location, cuisine: nil)

        flights = await fetchFlights
        hotels = await fetchHotels
        carRentals = await fetchCars
        restaurants = await fetchRestaurants
    }
}
