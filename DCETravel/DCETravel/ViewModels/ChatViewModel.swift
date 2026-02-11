import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    @Published var suggestedActions: [String] = []
    @Published var pendingNavigation: AppRoute?

    private var chatService: ChatServiceProtocol?
    private weak var appState: AppState?
    private var tripId: UUID?

    func loadChat(tripId: UUID, services: ServiceContainer, appState: AppState? = nil, pendingAction: String? = nil, showGreeting: Bool = true) async {
        self.chatService = services.chat
        self.appState = appState
        self.tripId = tripId

        // Load persisted messages
        if let persisted = appState?.chatMessages[tripId], !persisted.isEmpty {
            messages = persisted
            if let lastAgent = messages.last(where: { $0.sender == .agent }) {
                suggestedActions = contextualActions(for: lastAgent)
            } else {
                suggestedActions = defaultActions()
            }
        } else if showGreeting {
            suggestedActions = defaultActions()

            let greeting = ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "Hi! I'm ready to help plan your trip. I remember your last group trip was to Mexico City — let's make this one even better! What are you thinking for this trip?",
                timestamp: Date(),
                richContent: nil
            )

            withAnimation(.easeInOut(duration: 0.3)) {
                messages.append(greeting)
            }
            appState?.chatMessages[tripId] = messages
        } else {
            // Silent load for SearchResultsView — no greeting, no actions unless there are persisted messages
            suggestedActions = []
        }

        // If there's a pending action, send it automatically
        if let action = pendingAction {
            try? await Task.sleep(nanoseconds: 500_000_000)
            await sendMessage(action, tripId: tripId)
        }
    }

    private func defaultActions() -> [String] {
        ["Browse flights", "Browse hotels", "Rent a car", "Check my points", "My bookings"]
    }

    private func contextualActions(for response: ChatMessage) -> [String] {
        guard let rich = response.richContent else {
            return ["Browse flights", "Browse hotels", "Check my points"]
        }
        switch rich.type {
        case .hotelCard:
            return ["Book this hotel", "Browse more hotels", "Browse flights"]
        case .flightResults:
            return ["Book the first flight", "Browse more flights", "Browse hotels"]
        case .restaurantCard:
            return ["Reserve a table", "Browse restaurants", "Browse hotels"]
        case .carRentalResults:
            return ["Book this car", "Browse more cars", "Browse flights"]
        case .destinationResults:
            return ["Browse flights there", "Browse hotels there", "More destinations"]
        case .bookingConfirmation:
            return ["My bookings", "Browse flights", "Check my points"]
        case .bookingsList:
            return ["Browse flights", "Browse hotels", "Check my points"]
        case .itineraryThemes:
            return ["Tell me more", "Browse flights", "Browse hotels"]
        default:
            return ["Browse flights", "Browse hotels", "Check my points"]
        }
    }

    func sendMessage(_ text: String, tripId: UUID) async {
        guard let chatService = chatService else { return }

        // Add user message
        let userMessage = await chatService.sendMessage(text, tripId: tripId)
        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(userMessage)
        }

        // Show typing indicator
        withAnimation { isTyping = true }

        // Get AI response
        let response = await chatService.getAIResponse(for: text, tripId: tripId, context: messages)

        withAnimation { isTyping = false }

        withAnimation(.easeInOut(duration: 0.3)) {
            messages.append(response)
        }

        // Sync booking confirmations to AppState
        if let richContent = response.richContent,
           richContent.type == .bookingConfirmation,
           let booking = richContent.booking {
            appState?.addBooking(booking)
        }

        // Check for navigation intent from LLM
        if let chatService = chatService as? LLMChatService,
           let intent = chatService.consumeNavigationIntent() {
            pendingNavigation = mapNavigationIntent(intent.route, params: intent.params, tripId: tripId)
        }

        // Persist messages
        appState?.chatMessages[tripId] = messages

        // Update suggested actions based on response context
        withAnimation {
            suggestedActions = contextualActions(for: response)
        }
    }

    private func mapNavigationIntent(_ route: String, params: [String: String], tripId: UUID) -> AppRoute? {
        switch route {
        case "search":
            if let categoryStr = params["category"],
               let category = searchCategoryFromString(categoryStr) {
                return .searchResults(tripId: tripId, category: category)
            }
            return nil
        case "trip_overview":
            if let tripIdStr = params["trip_id"], let id = UUID(uuidString: tripIdStr) {
                return .tripReview(tripId: id)
            }
            return .tripReview(tripId: tripId)
        case "checkout":
            // Complex item lookup needed -- skip for now
            return nil
        default:
            return nil
        }
    }

    private func searchCategoryFromString(_ str: String) -> SearchCategory? {
        switch str.lowercased() {
        case "flights": return .flights
        case "hotels": return .hotels
        case "cars": return .cars
        case "restaurants": return .restaurants
        case "destinations": return .destinations
        default: return nil
        }
    }
}
