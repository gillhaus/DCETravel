import Foundation

class ServiceContainer {
    static let shared = ServiceContainer()

    let travel: TravelServiceProtocol
    let flights: FlightServiceProtocol
    let hotels: HotelServiceProtocol
    let restaurants: RestaurantServiceProtocol
    let bookings: BookingServiceProtocol
    let carRentals: CarRentalServiceProtocol
    let chat: ChatServiceProtocol
    let points: PointsServiceProtocol

    enum Mode {
        case mock
        case local(APIClient)
    }

    init(mode: Mode = .mock) {
        switch mode {
        case .mock:
            self.travel = MockTravelService()
            self.flights = MockFlightService()
            self.hotels = MockHotelService()
            self.restaurants = MockRestaurantService()
            self.bookings = MockBookingService()
            self.carRentals = MockCarRentalService()
            self.chat = MockChatService()
            self.points = MockPointsService()
        case .local(let client):
            let apiTravel = APITravelService(client: client)
            let apiFlights = APIFlightService(client: client)
            let apiHotels = APIHotelService(client: client)
            let apiRestaurants = APIRestaurantService(client: client)
            let apiBookings = APIBookingService(client: client)
            let apiCarRentals = APICarRentalService(client: client)
            let apiPoints = APIPointsService(client: client)
            self.travel = apiTravel
            self.flights = apiFlights
            self.hotels = apiHotels
            self.restaurants = apiRestaurants
            self.bookings = apiBookings
            self.carRentals = apiCarRentals
            self.points = apiPoints

            // Use LLM chat if API key is available, otherwise fallback to keyword agent
            let claudeAPIKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"]
            if let apiKey = claudeAPIKey, !apiKey.isEmpty {
                self.chat = LLMChatService(
                    apiKey: apiKey,
                    flights: apiFlights, hotels: apiHotels,
                    restaurants: apiRestaurants, carRentals: apiCarRentals,
                    bookings: apiBookings, travel: apiTravel,
                    points: apiPoints
                )
            } else {
                self.chat = AgentChatService(
                    flights: apiFlights, hotels: apiHotels,
                    restaurants: apiRestaurants, carRentals: apiCarRentals,
                    bookings: apiBookings,
                    travel: apiTravel, points: apiPoints
                )
            }
        }
    }

    init(
        travel: TravelServiceProtocol? = nil,
        flights: FlightServiceProtocol? = nil,
        hotels: HotelServiceProtocol? = nil,
        restaurants: RestaurantServiceProtocol? = nil,
        bookings: BookingServiceProtocol? = nil,
        carRentals: CarRentalServiceProtocol? = nil,
        chat: ChatServiceProtocol? = nil,
        points: PointsServiceProtocol? = nil
    ) {
        self.travel = travel ?? MockTravelService()
        self.flights = flights ?? MockFlightService()
        self.hotels = hotels ?? MockHotelService()
        self.restaurants = restaurants ?? MockRestaurantService()
        self.bookings = bookings ?? MockBookingService()
        self.carRentals = carRentals ?? MockCarRentalService()
        self.chat = chat ?? MockChatService()
        self.points = points ?? MockPointsService()
    }
}
