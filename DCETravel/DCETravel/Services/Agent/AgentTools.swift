import Foundation

enum AgentTool: String, CaseIterable {
    case searchDestinations
    case searchFlights
    case searchHotels
    case searchRestaurants
    case searchCars
    case bookFlight
    case bookHotel
    case bookRestaurant
    case bookCar
    case getCarDetails
    case getBookings
    case cancelBooking
    case getPointsBalance
    case calculatePointsValue
    case applyPointsBoost
    case getTrips
    case createTrip
    case getFlightStatus
    case getUserProfile
}

struct ToolResult {
    let tool: AgentTool
    let success: Bool
    let data: Any?
    let message: String
}

class ToolExecutor {
    let flights: FlightServiceProtocol
    let hotels: HotelServiceProtocol
    let restaurants: RestaurantServiceProtocol
    let carRentals: CarRentalServiceProtocol
    let bookings: BookingServiceProtocol
    let travel: TravelServiceProtocol
    let points: PointsServiceProtocol

    init(flights: FlightServiceProtocol, hotels: HotelServiceProtocol,
         restaurants: RestaurantServiceProtocol, carRentals: CarRentalServiceProtocol,
         bookings: BookingServiceProtocol,
         travel: TravelServiceProtocol, points: PointsServiceProtocol) {
        self.flights = flights
        self.hotels = hotels
        self.restaurants = restaurants
        self.carRentals = carRentals
        self.bookings = bookings
        self.travel = travel
        self.points = points
    }

    func execute(_ tool: AgentTool, parameters: [String: String]) async -> ToolResult {
        switch tool {
        case .searchDestinations:
            let query = parameters["query"] ?? ""
            let results = await travel.searchDestinations(query: query)
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No destinations found" : "Found \(results.count) destinations")

        case .searchFlights:
            let from = parameters["origin"] ?? "LAX"
            let to = parameters["destination"] ?? ""
            let results = await flights.searchFlights(from: from, to: to, date: Date())
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No flights found" : "Found \(results.count) flights")

        case .searchHotels:
            let destination = parameters["location"] ?? parameters["destination"] ?? ""
            let results = await hotels.searchHotels(destination: destination, checkIn: Date(), checkOut: Date().addingTimeInterval(86400 * 5))
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No hotels found" : "Found \(results.count) hotels")

        case .searchRestaurants:
            let location = parameters["location"] ?? ""
            let cuisine = parameters["cuisine"]
            let results = await restaurants.searchRestaurants(location: location, cuisine: cuisine)
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No restaurants found" : "Found \(results.count) restaurants")

        case .searchCars:
            let location = parameters["location"] ?? ""
            let results = await carRentals.searchCars(location: location, pickupDate: Date(), dropoffDate: Date().addingTimeInterval(86400 * 5))
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No car rentals found" : "Found \(results.count) car rentals")

        case .bookFlight:
            if let flightData = parameters["_flightData"],
               let data = flightData.data(using: .utf8),
               let flight = try? JSONDecoder.apiDecoder.decode(Flight.self, from: data) {
                let booking = await flights.bookFlight(flight)
                return ToolResult(tool: tool, success: booking.status == .confirmed,
                                data: booking,
                                message: "Flight booked! Confirmation: \(booking.confirmationNumber)")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No flight selected to book")

        case .bookHotel:
            if let hotelData = parameters["_hotelData"],
               let data = hotelData.data(using: .utf8),
               let hotel = try? JSONDecoder.apiDecoder.decode(Hotel.self, from: data) {
                let guests = parameters["guests"]?.components(separatedBy: ",") ?? ["Victoria"]
                let booking = await hotels.bookHotel(hotel, guests: guests)
                return ToolResult(tool: tool, success: booking.status == .confirmed,
                                data: booking,
                                message: "Hotel booked! Confirmation: \(booking.confirmationNumber)")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No hotel selected to book")

        case .bookRestaurant:
            if let restaurantIdStr = parameters["restaurantId"],
               let restaurantId = UUID(uuidString: restaurantIdStr) {
                let guests = Int(parameters["guests"] ?? "2") ?? 2
                let booking = await restaurants.bookTable(restaurantId: restaurantId, date: Date(), guests: guests)
                return ToolResult(tool: tool, success: booking.status == .confirmed,
                                data: booking,
                                message: "Restaurant reserved! Confirmation: \(booking.confirmationNumber)")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No restaurant selected to reserve")

        case .bookCar:
            if let carData = parameters["_carData"],
               let data = carData.data(using: .utf8),
               let car = try? JSONDecoder.apiDecoder.decode(CarRental.self, from: data) {
                let booking = await carRentals.bookCar(car)
                return ToolResult(tool: tool, success: booking.status == .confirmed,
                                data: booking,
                                message: "Car rental booked! Confirmation: \(booking.confirmationNumber)")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No car selected to book")

        case .getCarDetails:
            if let idStr = parameters["carId"], let id = UUID(uuidString: idStr) {
                let car = await carRentals.getCarDetails(carId: id)
                return ToolResult(tool: tool, success: car != nil, data: car,
                                message: car != nil ? "Car details loaded" : "Car not found")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No car ID provided")

        case .getBookings:
            let results = await bookings.getBookings()
            return ToolResult(tool: tool, success: true,
                            data: results,
                            message: results.isEmpty ? "No bookings found" : "You have \(results.count) bookings")

        case .cancelBooking:
            if let idStr = parameters["bookingId"], let id = UUID(uuidString: idStr) {
                let success = await bookings.cancelBooking(id: id)
                return ToolResult(tool: tool, success: success, data: nil,
                                message: success ? "Booking cancelled" : "Could not cancel booking")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No booking ID provided")

        case .getPointsBalance:
            let balance = await points.getBalance()
            return ToolResult(tool: tool, success: true, data: balance,
                            message: "Your balance is \(balance.formatted()) points")

        case .calculatePointsValue:
            let pts = Int(parameters["points"] ?? "0") ?? 0
            let value = await points.calculateValue(points: pts > 0 ? pts : 100_000)
            return ToolResult(tool: tool, success: true, data: value,
                            message: String(format: "%.0f points = $%.2f", Double(pts > 0 ? pts : 100_000), value))

        case .applyPointsBoost:
            let pts = Int(parameters["points"] ?? "100000") ?? 100_000
            let boosted = await points.applyBoost(points: pts)
            return ToolResult(tool: tool, success: true, data: boosted,
                            message: "\(pts.formatted()) points boosted to \(boosted.formatted()) points (33% bonus!)")

        case .getTrips:
            let results = await travel.getTripSuggestions()
            return ToolResult(tool: tool, success: !results.isEmpty,
                            data: results,
                            message: results.isEmpty ? "No trips found" : "Found \(results.count) trips")

        case .createTrip:
            return ToolResult(tool: tool, success: false, data: nil, message: "Use the planner to create trips")

        case .getFlightStatus:
            if let idStr = parameters["flightId"], let id = UUID(uuidString: idStr) {
                let flight = await flights.getFlightStatus(flightId: id)
                return ToolResult(tool: tool, success: true, data: flight,
                                message: "\(flight.flightNumber): \(flight.status.rawValue)")
            }
            return ToolResult(tool: tool, success: false, data: nil, message: "No flight ID provided")

        case .getUserProfile:
            return ToolResult(tool: tool, success: true, data: nil, message: "Profile loaded")
        }
    }
}
