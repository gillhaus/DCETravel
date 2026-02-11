import Foundation

struct ClaudeToolSchemas {
    static func allTools() -> [ClaudeAPIClient.ToolDefinition] {
        return [
            searchFlights, searchHotels, searchCars, searchRestaurants,
            bookFlight, bookHotel, bookCar, bookRestaurant,
            getBookings, cancelBooking,
            getPointsBalance, calculatePointsValue,
            searchDestinations, getFlightStatus, getTrips,
            navigateToSearch, navigateToCheckout, showTripOverview
        ]
    }

    static var searchFlights: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "search_flights",
            description: "Search for flights by origin, destination, date, and cabin class",
            input_schema: .init(
                type: "object",
                properties: [
                    "origin": .init(type: "string", description: "Departure airport code (e.g. LAX)", enum: nil),
                    "destination": .init(type: "string", description: "Arrival airport code or city name", enum: nil),
                    "cabin_class": .init(type: "string", description: "Cabin class preference", enum: ["Economy", "Premium Economy", "Business", "First"])
                ],
                required: nil
            )
        )
    }

    static var searchHotels: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "search_hotels",
            description: "Search for hotels by destination, dates, and preferences",
            input_schema: .init(
                type: "object",
                properties: [
                    "destination": .init(type: "string", description: "City or area to search for hotels", enum: nil),
                    "star_rating": .init(type: "integer", description: "Minimum star rating (1-5)", enum: nil),
                    "tier": .init(type: "string", description: "Hotel tier preference", enum: ["Standard", "Premium", "Luxury", "The Edit"])
                ],
                required: nil
            )
        )
    }

    static var searchCars: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "search_cars",
            description: "Search for car rentals by location and preferences",
            input_schema: .init(
                type: "object",
                properties: [
                    "location": .init(type: "string", description: "Pickup location city", enum: nil),
                    "car_type": .init(type: "string", description: "Type of car", enum: ["Compact", "Sedan", "SUV", "Luxury", "Convertible"])
                ],
                required: nil
            )
        )
    }

    static var searchRestaurants: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "search_restaurants",
            description: "Search for restaurants by location and cuisine type",
            input_schema: .init(
                type: "object",
                properties: [
                    "location": .init(type: "string", description: "City or area to search", enum: nil),
                    "cuisine": .init(type: "string", description: "Type of cuisine (e.g. Italian, Japanese)", enum: nil)
                ],
                required: nil
            )
        )
    }

    static var bookFlight: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "book_flight",
            description: "Book a specific flight by its ID. Use after searching for flights.",
            input_schema: .init(
                type: "object",
                properties: [
                    "flight_id": .init(type: "string", description: "The UUID of the flight to book", enum: nil),
                    "use_points": .init(type: "boolean", description: "Whether to pay with points instead of cash", enum: nil)
                ],
                required: ["flight_id"]
            )
        )
    }

    static var bookHotel: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "book_hotel",
            description: "Book a specific hotel by its ID. Use after searching for hotels.",
            input_schema: .init(
                type: "object",
                properties: [
                    "hotel_id": .init(type: "string", description: "The UUID of the hotel to book", enum: nil),
                    "use_points": .init(type: "boolean", description: "Whether to pay with points instead of cash", enum: nil)
                ],
                required: ["hotel_id"]
            )
        )
    }

    static var bookCar: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "book_car",
            description: "Book a specific car rental by its ID. Use after searching for cars.",
            input_schema: .init(
                type: "object",
                properties: [
                    "car_id": .init(type: "string", description: "The UUID of the car rental to book", enum: nil),
                    "use_points": .init(type: "boolean", description: "Whether to pay with points instead of cash", enum: nil)
                ],
                required: ["car_id"]
            )
        )
    }

    static var bookRestaurant: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "book_restaurant",
            description: "Reserve a table at a restaurant",
            input_schema: .init(
                type: "object",
                properties: [
                    "restaurant_id": .init(type: "string", description: "The UUID of the restaurant", enum: nil),
                    "guests": .init(type: "integer", description: "Number of guests", enum: nil)
                ],
                required: ["restaurant_id"]
            )
        )
    }

    static var getBookings: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "get_bookings",
            description: "List all current bookings, optionally filtered by trip",
            input_schema: .init(
                type: "object",
                properties: [
                    "trip_id": .init(type: "string", description: "Optional trip UUID to filter bookings", enum: nil)
                ],
                required: nil
            )
        )
    }

    static var cancelBooking: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "cancel_booking",
            description: "Cancel a booking by its ID",
            input_schema: .init(
                type: "object",
                properties: [
                    "booking_id": .init(type: "string", description: "The UUID of the booking to cancel", enum: nil)
                ],
                required: ["booking_id"]
            )
        )
    }

    static var getPointsBalance: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "get_points_balance",
            description: "Check the user's current points balance and membership tier",
            input_schema: .init(
                type: "object",
                properties: [:],
                required: nil
            )
        )
    }

    static var calculatePointsValue: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "calculate_points_value",
            description: "Calculate the dollar value of a given number of points",
            input_schema: .init(
                type: "object",
                properties: [
                    "points": .init(type: "integer", description: "Number of points to calculate value for", enum: nil)
                ],
                required: ["points"]
            )
        )
    }

    static var searchDestinations: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "search_destinations",
            description: "Search for travel destinations by name or interest",
            input_schema: .init(
                type: "object",
                properties: [
                    "query": .init(type: "string", description: "Search query for destinations", enum: nil)
                ],
                required: nil
            )
        )
    }

    static var getFlightStatus: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "get_flight_status",
            description: "Get the current status of a flight",
            input_schema: .init(
                type: "object",
                properties: [
                    "flight_id": .init(type: "string", description: "The UUID of the flight to check", enum: nil)
                ],
                required: ["flight_id"]
            )
        )
    }

    static var getTrips: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "get_trips",
            description: "List the user's trips",
            input_schema: .init(
                type: "object",
                properties: [:],
                required: nil
            )
        )
    }

    static var navigateToSearch: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "navigate_to_search",
            description: "Navigate the user to browse/search results for a category",
            input_schema: .init(
                type: "object",
                properties: [
                    "category": .init(type: "string", description: "The category to browse", enum: ["flights", "hotels", "cars", "restaurants", "destinations"]),
                    "trip_id": .init(type: "string", description: "Optional trip UUID to scope the search", enum: nil)
                ],
                required: ["category"]
            )
        )
    }

    static var navigateToCheckout: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "navigate_to_checkout",
            description: "Navigate the user to checkout for a specific item they want to book",
            input_schema: .init(
                type: "object",
                properties: [
                    "item_type": .init(type: "string", description: "The type of item to checkout", enum: ["flight", "hotel", "car", "restaurant"]),
                    "item_id": .init(type: "string", description: "The UUID of the item to checkout", enum: nil)
                ],
                required: ["item_type", "item_id"]
            )
        )
    }

    static var showTripOverview: ClaudeAPIClient.ToolDefinition {
        .init(
            name: "show_trip_overview",
            description: "Show the user their trip details/overview page",
            input_schema: .init(
                type: "object",
                properties: [
                    "trip_id": .init(type: "string", description: "Optional trip UUID. If not provided, shows the first active trip.", enum: nil)
                ],
                required: nil
            )
        )
    }
}
