import Foundation

class APIRouter {
    static func configure(router: Router, dataStore: DataStore) {
        let destinations = DestinationHandler(dataStore: dataStore)
        let flights = FlightHandler(dataStore: dataStore)
        let hotels = HotelHandler(dataStore: dataStore)
        let restaurants = RestaurantHandler(dataStore: dataStore)
        let cars = CarRentalHandler(dataStore: dataStore)
        let bookings = BookingHandler(dataStore: dataStore)
        let points = PointsHandler(dataStore: dataStore)
        let trips = TripHandler(dataStore: dataStore)
        let user = UserHandler(dataStore: dataStore)

        // Destinations
        router.get("/api/v1/destinations/search") { destinations.search($0) }
        router.get("/api/v1/destinations/inspiration") { destinations.inspiration($0) }
        router.get("/api/v1/destinations/:id") { destinations.getById($0) }

        // Flights
        router.post("/api/v1/flights/search") { flights.search($0) }
        router.get("/api/v1/flights/:id") { flights.getById($0) }
        router.post("/api/v1/flights/:id/book") { flights.book($0) }
        router.get("/api/v1/flights/:id/status") { flights.status($0) }

        // Hotels
        router.post("/api/v1/hotels/search") { hotels.search($0) }
        router.get("/api/v1/hotels/:id") { hotels.getById($0) }
        router.post("/api/v1/hotels/:id/book") { hotels.book($0) }
        router.post("/api/v1/hotels/:id/points-boost") { hotels.pointsBoost($0) }

        // Restaurants
        router.post("/api/v1/restaurants/search") { restaurants.search($0) }
        router.get("/api/v1/restaurants/:id/availability") { restaurants.availability($0) }
        router.post("/api/v1/restaurants/:id/reserve") { restaurants.reserve($0) }
        router.get("/api/v1/restaurants/:id") { restaurants.getById($0) }

        // Cars
        router.post("/api/v1/cars/search") { cars.search($0) }
        router.get("/api/v1/cars/:id") { cars.getById($0) }
        router.post("/api/v1/cars/:id/book") { cars.book($0) }

        // Bookings
        router.get("/api/v1/bookings") { bookings.list($0) }
        router.get("/api/v1/bookings/:id") { bookings.getById($0) }
        router.put("/api/v1/bookings/:id") { bookings.modify($0) }
        router.delete("/api/v1/bookings/:id") { bookings.cancel($0) }

        // Points
        router.get("/api/v1/points/balance") { points.balance($0) }
        router.post("/api/v1/points/calculate-value") { points.calculateValue($0) }
        router.post("/api/v1/points/apply-boost") { points.applyBoost($0) }

        // Trips
        router.get("/api/v1/trips") { trips.list($0) }
        router.post("/api/v1/trips") { trips.create($0) }
        router.get("/api/v1/trips/:id") { trips.getById($0) }
        router.put("/api/v1/trips/:id") { trips.update($0) }
        router.post("/api/v1/trips/:id/itinerary") { trips.setItinerary($0) }
        router.get("/api/v1/trips/:id/bookings") { trips.bookings($0) }

        // User
        router.get("/api/v1/user/profile") { user.profile($0) }
        router.get("/api/v1/user/preferences") { user.preferences($0) }
    }
}
