import Foundation

class AgentChatService: ChatServiceProtocol {
    private let toolExecutor: ToolExecutor
    private let intentParser: IntentParser
    private let planner: AgentPlanner
    private let formatter: AgentResponseFormatter
    private var contexts: [UUID: AgentContext] = [:]

    init(flights: FlightServiceProtocol, hotels: HotelServiceProtocol,
         restaurants: RestaurantServiceProtocol, carRentals: CarRentalServiceProtocol,
         bookings: BookingServiceProtocol,
         travel: TravelServiceProtocol, points: PointsServiceProtocol) {
        self.toolExecutor = ToolExecutor(
            flights: flights, hotels: hotels, restaurants: restaurants,
            carRentals: carRentals, bookings: bookings, travel: travel, points: points
        )
        self.intentParser = IntentParser(destinationNames: [
            "Tokyo", "Los Angeles", "Paris", "Cairo", "Bali", "Barcelona", "Rome",
            "New York", "London", "Dubai", "Sydney", "Bangkok"
        ])
        self.planner = AgentPlanner()
        self.formatter = AgentResponseFormatter()
    }

    func sendMessage(_ text: String, tripId: UUID) async -> ChatMessage {
        let message = ChatMessage(
            id: UUID(), sender: .user, text: text,
            timestamp: Date(), richContent: nil
        )
        getOrCreateContext(tripId: tripId).addMessage(message)
        return message
    }

    func getAIResponse(for message: String, tripId: UUID, context: [ChatMessage]) async -> ChatMessage {
        let agentContext = getOrCreateContext(tripId: tripId)
        let parsed = intentParser.parse(message, context: agentContext)

        let response: ChatMessage

        switch parsed.intent {
        case .greeting:
            response = formatter.formatGreeting(context: agentContext)

        case .confirmation:
            response = await handleConfirmation(agentContext)

        case .rejection:
            response = formatter.formatRejection(context: agentContext)
            agentContext.clearPendingAction()

        case .generalHelp:
            response = formatter.formatHelp()

        case .checkBenefits:
            let result = await toolExecutor.execute(.getPointsBalance, parameters: [:])
            response = formatter.formatResponse(for: parsed, toolResult: result, context: agentContext)

        case .followUp:
            if parsed.confidence < 0.4 {
                response = formatter.formatFollowUp()
            } else {
                response = await executePlan(for: parsed, context: agentContext)
            }

        default:
            if parsed.confidence < 0.5 {
                response = formatter.formatClarification(for: parsed)
            } else {
                response = await executePlan(for: parsed, context: agentContext)
            }
        }

        agentContext.addMessage(response)
        return response
    }

    func getSuggestedActions(tripId: UUID) async -> [String] {
        return [
            "Find hotels in Rome",
            "Search for flights",
            "Search for car rentals",
            "Check my points",
            "Show my bookings"
        ]
    }

    func getChatHistory(tripId: UUID) async -> [ChatMessage] {
        return contexts[tripId]?.conversationHistory ?? []
    }

    // MARK: - Private

    private func getOrCreateContext(tripId: UUID) -> AgentContext {
        if let existing = contexts[tripId] {
            return existing
        }
        let context = AgentContext(tripId: tripId)
        contexts[tripId] = context
        return context
    }

    private func executePlan(for intent: ParsedIntent, context: AgentContext) async -> ChatMessage {
        let plan = planner.createPlan(for: intent, context: context)

        guard !plan.steps.isEmpty else {
            return formatter.formatClarification(for: intent)
        }

        var lastResult: ToolResult?

        for step in plan.steps {
            if step.requiresConfirmation {
                context.setPendingAction(
                    mapToolToPendingType(step.tool),
                    description: step.description,
                    data: step
                )
                break
            }

            let result = await toolExecutor.execute(step.tool, parameters: step.parameters)
            lastResult = result

            if !result.success && plan.steps.count > 1 {
                break
            }
        }

        if let result = lastResult {
            return formatter.formatResponse(for: intent, toolResult: result, context: context)
        }

        return formatter.formatClarification(for: intent)
    }

    private func handleConfirmation(_ context: AgentContext) async -> ChatMessage {
        guard let pending = context.pendingAction else {
            return ChatMessage(id: UUID(), sender: .agent,
                             text: "I'm not sure what you'd like to confirm. Could you tell me more about what you'd like to do?",
                             timestamp: Date(), richContent: nil)
        }

        context.clearPendingAction()

        switch pending.type {
        case .bookHotel:
            if let hotel = pending.data as? Hotel,
               let hotelData = try? JSONEncoder.apiEncoder.encode(hotel),
               let hotelStr = String(data: hotelData, encoding: .utf8) {
                let result = await toolExecutor.execute(.bookHotel, parameters: ["_hotelData": hotelStr])
                return formatter.formatResponse(
                    for: ParsedIntent(intent: .bookHotel, confidence: 1.0, entities: [:]),
                    toolResult: result, context: context
                )
            }
        case .bookFlight:
            if let flight = pending.data as? Flight,
               let flightData = try? JSONEncoder.apiEncoder.encode(flight),
               let flightStr = String(data: flightData, encoding: .utf8) {
                let result = await toolExecutor.execute(.bookFlight, parameters: ["_flightData": flightStr])
                return formatter.formatResponse(
                    for: ParsedIntent(intent: .bookFlight, confidence: 1.0, entities: [:]),
                    toolResult: result, context: context
                )
            }
        case .bookRestaurant:
            if let restaurant = pending.data as? Restaurant {
                let result = await toolExecutor.execute(.bookRestaurant,
                                                        parameters: ["restaurantId": restaurant.id.uuidString])
                return formatter.formatResponse(
                    for: ParsedIntent(intent: .bookRestaurant, confidence: 1.0, entities: [:]),
                    toolResult: result, context: context
                )
            }
        case .bookCar:
            if let car = pending.data as? CarRental,
               let carData = try? JSONEncoder.apiEncoder.encode(car),
               let carStr = String(data: carData, encoding: .utf8) {
                let result = await toolExecutor.execute(.bookCar, parameters: ["_carData": carStr])
                return formatter.formatResponse(
                    for: ParsedIntent(intent: .bookCar, confidence: 1.0, entities: [:]),
                    toolResult: result, context: context
                )
            }
        default:
            break
        }

        return ChatMessage(id: UUID(), sender: .agent,
                         text: "I wasn't able to complete that action. Could you try again?",
                         timestamp: Date(), richContent: nil)
    }

    private func mapToolToPendingType(_ tool: AgentTool) -> AgentContext.PendingAction.PendingActionType {
        switch tool {
        case .bookHotel: return .bookHotel
        case .bookFlight: return .bookFlight
        case .bookRestaurant: return .bookRestaurant
        case .bookCar: return .bookCar
        case .cancelBooking: return .cancelBooking
        default: return .bookHotel
        }
    }
}
