import Foundation

class MockChatService: ChatServiceProtocol {
    private var messageHistory: [UUID: [ChatMessage]] = [:]

    func sendMessage(_ text: String, tripId: UUID) async -> ChatMessage {
        let message = ChatMessage(
            id: UUID(),
            sender: .user,
            text: text,
            timestamp: Date(),
            richContent: nil
        )
        messageHistory[tripId, default: []].append(message)
        return message
    }

    func getAIResponse(for message: String, tripId: UUID, context: [ChatMessage]) async -> ChatMessage {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...2_000_000_000))

        let lowered = message.lowercased()

        if lowered.contains("rome") || lowered.contains("italy") || lowered.contains("trip") {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "I'd love to help plan your trip to Rome! 🏛️ Based on your group's interests, I've put together some itinerary themes. Your last group trip was to Mexico City — this time, let's explore the Eternal City with a mix of history, amazing food, and luxury stays.",
                timestamp: Date(),
                richContent: ChatMessage.RichContent(
                    type: .itineraryThemes,
                    itineraryThemes: MockData.itineraryThemes
                )
            )
        } else if lowered.contains("hotel") || lowered.contains("stay") || lowered.contains("book") {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "Based on your preferences and Sapphire Reserve benefits, I've found the perfect hotel for your group. Portrait Roma is a 5-star property in a central location with stunning views. I've applied Points Boost to maximize your savings.",
                timestamp: Date(),
                richContent: ChatMessage.RichContent(
                    type: .hotelCard,
                    hotel: MockData.hotels[0]
                )
            )
        } else if lowered.contains("restaurant") || lowered.contains("food") || lowered.contains("dinner") || lowered.contains("eat") {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "I checked restaurant availability for your group. Here's a wonderful option near the Pantheon — it's known for authentic Roman cuisine and has excellent reviews.",
                timestamp: Date(),
                richContent: ChatMessage.RichContent(
                    type: .restaurantCard,
                    restaurant: MockData.restaurants[0]
                )
            )
        } else if lowered.contains("flight") {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "I found several flight options for your trip. Here are the best options based on your preferred airlines and schedule preferences.",
                timestamp: Date(),
                richContent: nil
            )
        } else if lowered.contains("lounge") || lowered.contains("airport") {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "Great news! As a Sapphire Reserve cardholder, you have access to the Prima Vista Lounge in Terminal E. I've reserved spots for your group.",
                timestamp: Date(),
                richContent: ChatMessage.RichContent(
                    type: .loungeCard,
                    imageURL: "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800"
                )
            )
        } else {
            return ChatMessage(
                id: UUID(),
                sender: .agent,
                text: "I'm here to help with your travel plans! I can assist with finding destinations, booking hotels and flights, making restaurant reservations, and managing your itinerary. What would you like to explore?",
                timestamp: Date(),
                richContent: nil
            )
        }
    }

    func getSuggestedActions(tripId: UUID) async -> [String] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return [
            "Find hotels in Rome",
            "Book a restaurant",
            "Check flight options",
            "Plan daily itinerary",
            "Airport lounge access"
        ]
    }

    func getChatHistory(tripId: UUID) async -> [ChatMessage] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...600_000_000))
        return messageHistory[tripId] ?? []
    }
}
