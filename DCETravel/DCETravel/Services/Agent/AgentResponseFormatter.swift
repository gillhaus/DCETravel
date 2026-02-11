import Foundation

class AgentResponseFormatter {

    func formatResponse(for intent: ParsedIntent, toolResult: ToolResult, context: AgentContext) -> ChatMessage {
        switch toolResult.tool {
        case .searchHotels:
            return formatHotelResults(toolResult, intent: intent, context: context)
        case .searchFlights:
            return formatFlightResults(toolResult, intent: intent, context: context)
        case .searchRestaurants:
            return formatRestaurantResults(toolResult, intent: intent, context: context)
        case .searchCars:
            return formatCarResults(toolResult, intent: intent, context: context)
        case .searchDestinations:
            return formatDestinationResults(toolResult, intent: intent, context: context)
        case .getBookings:
            return formatBookingResults(toolResult, context: context)
        case .bookFlight, .bookHotel, .bookRestaurant, .bookCar:
            return formatBookingConfirmation(toolResult)
        case .cancelBooking:
            return formatCancellation(toolResult)
        case .getPointsBalance:
            return formatPointsBalance(toolResult, intent: intent)
        case .calculatePointsValue:
            return formatPointsValue(toolResult)
        case .applyPointsBoost:
            return formatPointsBoost(toolResult)
        case .getTrips:
            return formatTripResults(toolResult)
        case .getFlightStatus:
            return formatFlightStatus(toolResult)
        default:
            return makeMessage(toolResult.message)
        }
    }

    func formatGreeting(context: AgentContext) -> ChatMessage {
        return makeMessage("Hi! I'm your travel concierge. I can help you search for flights, hotels, and restaurants, manage your bookings, check your points, and plan amazing trips. What would you like to do?")
    }

    func formatClarification(for intent: ParsedIntent) -> ChatMessage {
        switch intent.intent {
        case .searchFlights:
            return makeMessage("I'd love to help find flights! Could you tell me where you'd like to fly to? And if you have preferred dates, that would help narrow things down.")
        case .searchHotels:
            return makeMessage("I can help find the perfect hotel! Which city or destination are you looking at?")
        case .searchRestaurants:
            return makeMessage("I know some great spots! What kind of cuisine are you in the mood for, and what area?")
        case .searchCars:
            return makeMessage("I can help find a rental car! What city or airport do you need it from, and what dates?")
        case .planTrip:
            return makeMessage("I'd love to help plan a trip! Where are you thinking of going? I can suggest destinations, find flights, hotels, and restaurants.")
        default:
            return makeMessage("I can help with flights, hotels, restaurants, bookings, points, and trip planning. What would you like to explore?")
        }
    }

    func formatRejection(context: AgentContext) -> ChatMessage {
        if context.lastSearchResults?.hotels != nil {
            return makeMessage("No problem! Would you like me to search for different hotels, or would you prefer to look at something else entirely?")
        }
        if context.lastSearchResults?.flights != nil {
            return makeMessage("Got it. Want me to search for different flights, maybe on different dates or with a different airline?")
        }
        if context.lastSearchResults?.restaurants != nil {
            return makeMessage("Sure thing. Want me to look for a different type of cuisine or in a different area?")
        }
        if context.lastSearchResults?.carRentals != nil {
            return makeMessage("No problem. Want me to search for a different type of car or from a different company?")
        }
        return makeMessage("No worries! What else can I help you with?")
    }

    func formatBenefits() -> ChatMessage {
        return makeMessage("As a Sapphire Reserve member, you enjoy:\n\n• 33% Points Boost on hotel bookings\n• Airport lounge access worldwide\n• Priority boarding on partner airlines\n• Complimentary room upgrades at select hotels\n• $100 property credit at The Edit hotels\n• Concierge service 24/7\n\nWould you like to see how to maximize these benefits on your next trip?")
    }

    func formatHelp() -> ChatMessage {
        return makeMessage("Here's what I can help with:\n\n✈️ **Flights** — Search, compare, and book flights\n🏨 **Hotels** — Find and book hotels with Points Boost\n🚗 **Car Rentals** — Find and book rental cars\n🍽️ **Restaurants** — Discover and reserve restaurants\n📋 **Bookings** — View, modify, or cancel reservations\n⭐ **Points** — Check balance, calculate value, maximize rewards\n🗺️ **Trips** — Plan new trips and get destination inspiration\n\nJust ask me anything!")
    }

    func formatFollowUp() -> ChatMessage {
        return makeMessage("I'm not quite sure what you mean. Could you tell me more about what you're looking for? I can help with flights, hotels, restaurants, bookings, or points.")
    }

    // MARK: - Domain-Specific Formatters

    private func formatHotelResults(_ result: ToolResult, intent: ParsedIntent, context: AgentContext) -> ChatMessage {
        guard let hotels = result.data as? [Hotel], !hotels.isEmpty else {
            return makeMessage("I couldn't find any hotels matching your search. Want me to try different criteria?")
        }

        context.setLastSearch(hotels: hotels)
        context.lastDomain = "hotel"

        // Show the top hotel as a rich card
        let topHotel = hotels[0]
        let location = intent.entities["location"] ?? topHotel.location
        var text = "I found \(hotels.count) great hotel\(hotels.count == 1 ? "" : "s") in \(location). Here's my top recommendation:"

        if hotels.count > 1 {
            text += "\n\nI also found "
            let others = hotels.dropFirst().prefix(2)
            text += others.map { "\($0.name) (\($0.starRating)★, \($0.pointsCost.formatted()) pts)" }.joined(separator: " and ")
            text += ". Want to see details on any of these?"
        }

        // Set pending action for booking
        context.setPendingAction(.bookHotel, description: "Book \(topHotel.name)", data: topHotel)

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .hotelCard, imageURL: nil,
                hotel: topHotel, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatFlightResults(_ result: ToolResult, intent: ParsedIntent, context: AgentContext) -> ChatMessage {
        guard let flights = result.data as? [Flight], !flights.isEmpty else {
            return makeMessage("I couldn't find any flights matching your criteria. Want me to try different dates or routes?")
        }

        context.setLastSearch(flights: flights)
        context.lastDomain = "flight"
        context.setPendingAction(.bookFlight, description: "Book flight", data: flights[0])

        var text = "I found \(flights.count) flight\(flights.count == 1 ? "" : "s"):\n\n"
        for (i, flight) in flights.enumerated() {
            text += "**\(i + 1). \(flight.airline) \(flight.flightNumber)**\n"
            text += "   \(flight.departureAirport) → \(flight.arrivalAirport) • \(flight.cabinClass.rawValue)\n"
            text += "   $\(Int(flight.price)) or \(flight.pointsCost.formatted()) points\n"
            if i < flights.count - 1 { text += "\n" }
        }
        text += "\nWould you like to book one of these?"

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .flightResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: flights, destinations: nil, bookings: nil,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatRestaurantResults(_ result: ToolResult, intent: ParsedIntent, context: AgentContext) -> ChatMessage {
        guard let restaurants = result.data as? [Restaurant], !restaurants.isEmpty else {
            return makeMessage("I couldn't find any restaurants matching your preferences. Want me to try a different cuisine or location?")
        }

        context.setLastSearch(restaurants: restaurants)
        context.lastDomain = "restaurant"

        let top = restaurants[0]
        context.setPendingAction(.bookRestaurant, description: "Reserve \(top.name)", data: top)

        var text = "I found \(restaurants.count) restaurant\(restaurants.count == 1 ? "" : "s"). Here's my top pick:"

        if restaurants.count > 1 {
            text += "\n\nAlso available: "
            text += restaurants.dropFirst().prefix(2).map { "\($0.name) (\($0.cuisine), \($0.rating)★)" }.joined(separator: " and ")
        }

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .restaurantCard, imageURL: nil,
                hotel: nil, restaurant: top,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatCarResults(_ result: ToolResult, intent: ParsedIntent, context: AgentContext) -> ChatMessage {
        guard let cars = result.data as? [CarRental], !cars.isEmpty else {
            return makeMessage("I couldn't find any car rentals matching your search. Want me to try different criteria?")
        }

        context.setLastSearch(carRentals: cars)
        context.lastDomain = "car"

        let top = cars[0]
        context.setPendingAction(.bookCar, description: "Book \(top.company) \(top.model)", data: top)

        var text = "I found \(cars.count) car rental\(cars.count == 1 ? "" : "s"). Here's my top pick:"

        if cars.count > 1 {
            text += "\n\nAlso available: "
            text += cars.dropFirst().prefix(2).map { "\($0.company) \($0.model) ($\(Int($0.pricePerDay))/day)" }.joined(separator: " and ")
        }

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .carRentalResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: cars,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatDestinationResults(_ result: ToolResult, intent: ParsedIntent, context: AgentContext) -> ChatMessage {
        guard let destinations = result.data as? [Destination], !destinations.isEmpty else {
            return makeMessage("I don't have information about that destination yet. Would you like to see some popular destinations for inspiration?")
        }

        context.setLastSearch(destinations: destinations)
        context.lastDomain = "trip"

        if destinations.count == 1 {
            let dest = destinations[0]
            return makeMessage("**\(dest.name), \(dest.country)** — \(dest.description)\n\nTags: \(dest.tags.joined(separator: ", "))\(dest.suggestedDates.map { "\nSuggested dates: \($0)" } ?? "")\n\nWould you like me to search for flights and hotels for \(dest.name)?")
        }

        var text = "Here are some great destinations:\n\n"
        for dest in destinations.prefix(4) {
            text += "🌍 **\(dest.name), \(dest.country)** — \(dest.tags.prefix(3).joined(separator: ", "))\n"
        }
        text += "\nWant to explore any of these? I can find flights, hotels, and restaurants."

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .destinationResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: destinations, bookings: nil,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatBookingResults(_ result: ToolResult, context: AgentContext) -> ChatMessage {
        guard let bookingList = result.data as? [Booking], !bookingList.isEmpty else {
            return makeMessage("You don't have any bookings yet. Would you like to search for flights or hotels?")
        }

        context.setLastSearch(bookings: bookingList)
        context.lastDomain = "booking"

        var text = "Here are your current bookings:\n\n"
        for booking in bookingList {
            let icon = booking.type == .flight ? "✈️" : booking.type == .hotel ? "🏨" : "🍽️"
            text += "\(icon) **\(booking.details)**\n   \(booking.status.rawValue) • \(booking.confirmationNumber)\n\n"
        }
        text += "Would you like to modify or cancel any of these?"

        return ChatMessage(
            id: UUID(), sender: .agent, text: text, timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .bookingsList, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: bookingList,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatBookingConfirmation(_ result: ToolResult) -> ChatMessage {
        guard let booking = result.data as? Booking else {
            return makeMessage(result.success ? "Booking confirmed!" : "Sorry, there was an issue with the booking. Please try again.")
        }

        return ChatMessage(
            id: UUID(), sender: .agent,
            text: "Great news! Your booking is confirmed.\n\n📋 **Confirmation:** \(booking.confirmationNumber)\n📝 \(booking.details)\n✅ Status: \(booking.status.rawValue)",
            timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .bookingConfirmation, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: booking,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil,
                linkText: nil, linkURL: nil
            )
        )
    }

    private func formatCancellation(_ result: ToolResult) -> ChatMessage {
        if result.success {
            return makeMessage("Your booking has been cancelled. Is there anything else I can help with?")
        }
        return makeMessage("I wasn't able to cancel that booking. Would you like me to try again or help with something else?")
    }

    private func formatPointsBalance(_ result: ToolResult, intent: ParsedIntent) -> ChatMessage {
        guard let balance = result.data as? Int else {
            return makeMessage("I couldn't retrieve your points balance. Please try again.")
        }

        if intent.intent == .checkBenefits {
            return makeMessage("**Your Sapphire Reserve Benefits:**\n\n⭐ Points Balance: **\(balance.formatted()) points** ($\(String(format: "%.0f", Double(balance) / 100.0)) value)\n\n• 33% Points Boost on hotel bookings\n• Airport lounge access worldwide\n• Priority boarding\n• Complimentary room upgrades\n• $100 property credit at The Edit hotels\n\nWould you like to see how to maximize your points?")
        }

        return makeMessage("Your current balance is **\(balance.formatted()) points**, worth approximately **$\(String(format: "%.0f", Double(balance) / 100.0))**.\n\nAs a Sapphire Reserve member, you get a 33% Points Boost on hotel bookings! Would you like to see how to maximize your points?")
    }

    private func formatPointsValue(_ result: ToolResult) -> ChatMessage {
        return makeMessage(result.message)
    }

    private func formatPointsBoost(_ result: ToolResult) -> ChatMessage {
        return makeMessage("**Points Boost Analysis:**\n\n\(result.message)\n\nThe 33% Points Boost applies automatically to hotel bookings through your Sapphire Reserve card. Would you like to search for hotels to use your boosted points?")
    }

    private func formatTripResults(_ result: ToolResult) -> ChatMessage {
        guard let trips = result.data as? [Trip], !trips.isEmpty else {
            return makeMessage("You don't have any trips yet. Would you like to start planning one?")
        }

        var text = "Here are your trips:\n\n"
        for trip in trips {
            text += "🗺️ **\(trip.name)** — \(trip.destination), \(trip.destinationCountry)\n"
            text += "   \(trip.dateRangeText) • \(trip.status.rawValue)\n\n"
        }
        text += "Would you like to continue planning any of these, or start a new trip?"

        return makeMessage(text)
    }

    private func formatFlightStatus(_ result: ToolResult) -> ChatMessage {
        if let flight = result.data as? Flight {
            return makeMessage("**Flight \(flight.flightNumber) Status:**\n\n✈️ \(flight.departureAirport) → \(flight.arrivalAirport)\n📊 Status: **\(flight.status.rawValue)**\n⏰ Departure: \(flight.departureTime.formatted())\n⏰ Arrival: \(flight.arrivalTime.formatted())")
        }
        return makeMessage(result.message)
    }

    // MARK: - Helpers

    private func makeMessage(_ text: String) -> ChatMessage {
        ChatMessage(id: UUID(), sender: .agent, text: text, timestamp: Date(), richContent: nil)
    }
}
