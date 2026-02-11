import Foundation

class LLMChatService: ChatServiceProtocol {
    private let claude: ClaudeAPIClient
    private let flights: FlightServiceProtocol
    private let hotels: HotelServiceProtocol
    private let restaurants: RestaurantServiceProtocol
    private let carRentals: CarRentalServiceProtocol
    private let bookings: BookingServiceProtocol
    private let travel: TravelServiceProtocol
    private let points: PointsServiceProtocol
    private var conversationHistories: [UUID: [ClaudeAPIClient.MessagesRequest.Message]] = [:]

    // Track last tool results for rich content mapping
    private var lastToolResults: [String: Any] = [:]

    // Navigation intent tracking
    var pendingNavigationRoute: String?
    var pendingNavigationParams: [String: String] = [:]
    private var lastNavigationIntent: (route: String, params: [String: String])?

    init(apiKey: String,
         flights: FlightServiceProtocol, hotels: HotelServiceProtocol,
         restaurants: RestaurantServiceProtocol, carRentals: CarRentalServiceProtocol,
         bookings: BookingServiceProtocol, travel: TravelServiceProtocol,
         points: PointsServiceProtocol) {
        self.claude = ClaudeAPIClient(apiKey: apiKey)
        self.flights = flights
        self.hotels = hotels
        self.restaurants = restaurants
        self.carRentals = carRentals
        self.bookings = bookings
        self.travel = travel
        self.points = points
    }

    func sendMessage(_ text: String, tripId: UUID) async -> ChatMessage {
        return ChatMessage(
            id: UUID(), sender: .user, text: text,
            timestamp: Date(), richContent: nil
        )
    }

    func getAIResponse(for message: String, tripId: UUID, context: [ChatMessage]) async -> ChatMessage {
        lastToolResults = [:]

        // Build conversation history
        var messages = conversationHistories[tripId] ?? []
        messages.append(.init(role: "user", content: .text(message)))

        let systemPrompt = buildSystemPrompt(tripId: tripId)
        let tools = ClaudeToolSchemas.allTools()

        // Tool use loop
        var currentMessages = messages
        let maxIterations = 10

        for _ in 0..<maxIterations {
            do {
                let response = try await claude.sendMessages(
                    system: systemPrompt,
                    messages: currentMessages,
                    tools: tools
                )

                // Check if we have tool_use blocks
                let toolUseBlocks = response.content.filter { $0.type == "tool_use" }
                let textBlocks = response.content.filter { $0.type == "text" }

                if toolUseBlocks.isEmpty || response.stop_reason == "end_turn" {
                    // No more tools to call — extract final text
                    let responseText = textBlocks.map { $0.text ?? "" }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    let finalText = responseText.isEmpty ? "I've completed the request." : responseText

                    // Save conversation
                    currentMessages.append(.init(role: "assistant", content: .text(finalText)))
                    conversationHistories[tripId] = currentMessages

                    // Build rich content from last tool results
                    let richContent = buildRichContent()

                    // Check for pending navigation intent
                    if let navRoute = pendingNavigationRoute {
                        lastNavigationIntent = (route: navRoute, params: pendingNavigationParams)
                    }

                    return ChatMessage(
                        id: UUID(), sender: .agent, text: finalText,
                        timestamp: Date(), richContent: richContent
                    )
                }

                // Build assistant response content blocks
                var assistantBlocks: [ClaudeAPIClient.ContentBlock] = []
                for block in response.content {
                    if block.type == "text" {
                        assistantBlocks.append(.init(type: "text", text: block.text))
                    } else if block.type == "tool_use" {
                        assistantBlocks.append(.init(
                            type: "tool_use", id: block.id,
                            name: block.name, input: block.input
                        ))
                    }
                }
                currentMessages.append(.init(role: "assistant", content: .blocks(assistantBlocks)))

                // Execute each tool and build tool_result blocks
                var toolResultBlocks: [ClaudeAPIClient.ContentBlock] = []
                for toolBlock in toolUseBlocks {
                    guard let toolName = toolBlock.name, let toolId = toolBlock.id else { continue }
                    let input = toolBlock.input ?? [:]
                    let resultStr = await executeToolCall(name: toolName, input: input)
                    toolResultBlocks.append(.init(
                        type: "tool_result",
                        tool_use_id: toolId,
                        content: resultStr
                    ))
                }
                currentMessages.append(.init(role: "user", content: .blocks(toolResultBlocks)))

            } catch {
                // API error — return graceful fallback
                conversationHistories[tripId] = currentMessages
                return ChatMessage(
                    id: UUID(), sender: .agent,
                    text: "I'm having trouble connecting right now. Could you try again in a moment?",
                    timestamp: Date(), richContent: nil
                )
            }
        }

        // Max iterations reached
        conversationHistories[tripId] = currentMessages
        return ChatMessage(
            id: UUID(), sender: .agent,
            text: "I've been working on your request but it's taking longer than expected. Could you try a simpler query?",
            timestamp: Date(), richContent: nil
        )
    }

    func getSuggestedActions(tripId: UUID) async -> [String] {
        return [
            "Find flights to Rome",
            "Search for hotels",
            "Rent a car",
            "Check my points balance",
            "Show my bookings"
        ]
    }

    func getChatHistory(tripId: UUID) async -> [ChatMessage] {
        return []
    }

    func consumeNavigationIntent() -> (route: String, params: [String: String])? {
        guard let intent = lastNavigationIntent else { return nil }
        lastNavigationIntent = nil
        pendingNavigationRoute = nil
        pendingNavigationParams = [:]
        return intent
    }

    // MARK: - System Prompt

    private func buildSystemPrompt(tripId: UUID) -> String {
        return """
        You are a premium travel concierge for a luxury travel rewards card program. \
        The user is Victoria Chen, a Sapphire Reserve cardholder with 2,450,000 points. \
        She is planning trips and managing bookings.

        Key benefits of her membership:
        - 33% Points Boost on hotel bookings
        - Airport lounge access worldwide
        - Priority boarding
        - Complimentary room upgrades at select hotels
        - $500 statement credit and $300 annual travel credit

        When helping the user:
        1. Be warm, professional, and concise
        2. Use the available tools to search and book travel
        3. Always show prices in both dollars and points when available
        4. Proactively mention relevant card benefits
        5. When showing search results, highlight the top recommendation
        6. Ask for confirmation before booking anything

        Navigation tools available:
        - Use `navigate_to_search` when the user wants to browse or see a list of flights, hotels, cars, restaurants, or destinations. Always use this AFTER presenting your text response.
        - Use `navigate_to_checkout` when the user wants to book a specific item you've shown them.
        - Use `show_trip_overview` when the user asks to see their trip details or itinerary.

        When navigating: First provide a helpful text response, then call the navigation tool. The app will navigate after showing your message.

        Current trip context: Trip ID \(tripId.uuidString)
        """
    }

    // MARK: - Tool Execution

    private func executeToolCall(name: String, input: [String: AnyCodable]) async -> String {
        switch name {
        case "search_flights":
            let from = input["origin"]?.stringValue ?? "LAX"
            let to = input["destination"]?.stringValue ?? ""
            let results = await flights.searchFlights(from: from, to: to, date: Date())
            lastToolResults["search_flights"] = results
            return encodeResults(results)

        case "search_hotels":
            let dest = input["destination"]?.stringValue ?? ""
            let results = await hotels.searchHotels(destination: dest, checkIn: Date(), checkOut: Date().addingTimeInterval(86400 * 5))
            lastToolResults["search_hotels"] = results
            return encodeResults(results)

        case "search_cars":
            let location = input["location"]?.stringValue ?? ""
            let results = await carRentals.searchCars(location: location, pickupDate: Date(), dropoffDate: Date().addingTimeInterval(86400 * 5))
            lastToolResults["search_cars"] = results
            return encodeResults(results)

        case "search_restaurants":
            let location = input["location"]?.stringValue ?? ""
            let cuisine = input["cuisine"]?.stringValue
            let results = await restaurants.searchRestaurants(location: location, cuisine: cuisine)
            lastToolResults["search_restaurants"] = results
            return encodeResults(results)

        case "book_flight":
            if let idStr = input["flight_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                // Find the flight from last search results
                if let searchResults = lastToolResults["search_flights"] as? [Flight],
                   let flight = searchResults.first(where: { $0.id == id }) {
                    let booking = await flights.bookFlight(flight)
                    lastToolResults["book_flight"] = booking
                    return encodeResults(booking)
                }
                // Try getting flight status as fallback
                let flight = await flights.getFlightStatus(flightId: id)
                let booking = await flights.bookFlight(flight)
                lastToolResults["book_flight"] = booking
                return encodeResults(booking)
            }
            return "{\"error\": \"Invalid flight ID\"}"

        case "book_hotel":
            if let idStr = input["hotel_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                if let searchResults = lastToolResults["search_hotels"] as? [Hotel],
                   let hotel = searchResults.first(where: { $0.id == id }) {
                    let booking = await hotels.bookHotel(hotel, guests: ["Victoria"])
                    lastToolResults["book_hotel"] = booking
                    return encodeResults(booking)
                }
                let hotel = await hotels.getHotelDetails(hotelId: id)
                let booking = await hotels.bookHotel(hotel, guests: ["Victoria"])
                lastToolResults["book_hotel"] = booking
                return encodeResults(booking)
            }
            return "{\"error\": \"Invalid hotel ID\"}"

        case "book_car":
            if let idStr = input["car_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                if let searchResults = lastToolResults["search_cars"] as? [CarRental],
                   let car = searchResults.first(where: { $0.id == id }) {
                    let booking = await carRentals.bookCar(car)
                    lastToolResults["book_car"] = booking
                    return encodeResults(booking)
                }
                if let car = await carRentals.getCarDetails(carId: id) {
                    let booking = await carRentals.bookCar(car)
                    lastToolResults["book_car"] = booking
                    return encodeResults(booking)
                }
            }
            return "{\"error\": \"Invalid car ID\"}"

        case "book_restaurant":
            if let idStr = input["restaurant_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                let guests = input["guests"]?.intValue ?? 2
                let booking = await restaurants.bookTable(restaurantId: id, date: Date(), guests: guests)
                lastToolResults["book_restaurant"] = booking
                return encodeResults(booking)
            }
            return "{\"error\": \"Invalid restaurant ID\"}"

        case "get_bookings":
            let results: [Booking]
            if let tripIdStr = input["trip_id"]?.stringValue, let tripId = UUID(uuidString: tripIdStr) {
                results = await bookings.getBookings(tripId: tripId)
            } else {
                results = await bookings.getBookings()
            }
            lastToolResults["get_bookings"] = results
            return encodeResults(results)

        case "cancel_booking":
            if let idStr = input["booking_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                let success = await bookings.cancelBooking(id: id)
                return "{\"success\": \(success)}"
            }
            return "{\"error\": \"Invalid booking ID\"}"

        case "get_points_balance":
            let balance = await points.getBalance()
            lastToolResults["get_points_balance"] = balance
            return "{\"balance\": \(balance), \"tier\": \"Sapphire Reserve\", \"value_usd\": \(String(format: "%.2f", Double(balance) / 100.0))}"

        case "calculate_points_value":
            let pts = input["points"]?.intValue ?? 100_000
            let value = await points.calculateValue(points: pts)
            return "{\"points\": \(pts), \"value_usd\": \(String(format: "%.2f", value))}"

        case "search_destinations":
            let query = input["query"]?.stringValue ?? ""
            let results = await travel.searchDestinations(query: query)
            lastToolResults["search_destinations"] = results
            return encodeResults(results)

        case "get_flight_status":
            if let idStr = input["flight_id"]?.stringValue, let id = UUID(uuidString: idStr) {
                let flight = await flights.getFlightStatus(flightId: id)
                return encodeResults(flight)
            }
            return "{\"error\": \"Invalid flight ID\"}"

        case "get_trips":
            let results = await travel.getTripSuggestions()
            return encodeResults(results)

        case "navigate_to_search":
            let category = input["category"]?.stringValue ?? "flights"
            pendingNavigationRoute = "search"
            pendingNavigationParams = ["category": category]
            if let tripIdStr = input["trip_id"]?.stringValue {
                pendingNavigationParams["trip_id"] = tripIdStr
            }
            return "{\"action\": \"navigate_to_search\", \"category\": \"\(category)\", \"status\": \"navigation_queued\"}"

        case "navigate_to_checkout":
            let itemType = input["item_type"]?.stringValue ?? ""
            let itemId = input["item_id"]?.stringValue ?? ""
            pendingNavigationRoute = "checkout"
            pendingNavigationParams = ["item_type": itemType, "item_id": itemId]
            return "{\"action\": \"navigate_to_checkout\", \"item_type\": \"\(itemType)\", \"item_id\": \"\(itemId)\", \"status\": \"navigation_queued\"}"

        case "show_trip_overview":
            pendingNavigationRoute = "trip_overview"
            if let tripIdStr = input["trip_id"]?.stringValue {
                pendingNavigationParams = ["trip_id": tripIdStr]
            }
            return "{\"action\": \"show_trip_overview\", \"status\": \"navigation_queued\"}"

        default:
            return "{\"error\": \"Unknown tool: \(name)\"}"
        }
    }

    private func encodeResults<T: Encodable>(_ value: T) -> String {
        let encoder = JSONEncoder.apiEncoder
        guard let data = try? encoder.encode(value),
              let str = String(data: data, encoding: .utf8) else {
            return "{\"error\": \"Failed to encode results\"}"
        }
        return str
    }

    // MARK: - Rich Content Building

    private func buildRichContent() -> ChatMessage.RichContent? {
        // Priority: booking confirmation > search results
        if let booking = lastToolResults["book_flight"] as? Booking ??
           lastToolResults["book_hotel"] as? Booking ??
           lastToolResults["book_car"] as? Booking ??
           lastToolResults["book_restaurant"] as? Booking {
            return ChatMessage.RichContent(
                type: .bookingConfirmation, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: booking,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        if let hotels = lastToolResults["search_hotels"] as? [Hotel], let top = hotels.first {
            return ChatMessage.RichContent(
                type: .hotelCard, imageURL: nil,
                hotel: top, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        if let flights = lastToolResults["search_flights"] as? [Flight], !flights.isEmpty {
            return ChatMessage.RichContent(
                type: .flightResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: flights, destinations: nil, bookings: nil,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        if let cars = lastToolResults["search_cars"] as? [CarRental], !cars.isEmpty {
            return ChatMessage.RichContent(
                type: .carRentalResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: cars, linkText: nil, linkURL: nil
            )
        }

        if let restaurants = lastToolResults["search_restaurants"] as? [Restaurant], let top = restaurants.first {
            return ChatMessage.RichContent(
                type: .restaurantCard, imageURL: nil,
                hotel: nil, restaurant: top,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: nil,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        if let destinations = lastToolResults["search_destinations"] as? [Destination], !destinations.isEmpty {
            return ChatMessage.RichContent(
                type: .destinationResults, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: destinations, bookings: nil,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        if let bookingsList = lastToolResults["get_bookings"] as? [Booking], !bookingsList.isEmpty {
            return ChatMessage.RichContent(
                type: .bookingsList, imageURL: nil,
                hotel: nil, restaurant: nil,
                itineraryThemes: nil, booking: nil,
                flights: nil, destinations: nil, bookings: bookingsList,
                carRentals: nil, linkText: nil, linkURL: nil
            )
        }

        return nil
    }
}
