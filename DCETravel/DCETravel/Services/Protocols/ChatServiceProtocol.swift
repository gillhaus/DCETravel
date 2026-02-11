import Foundation

protocol ChatServiceProtocol {
    func sendMessage(_ text: String, tripId: UUID) async -> ChatMessage
    func getAIResponse(for message: String, tripId: UUID, context: [ChatMessage]) async -> ChatMessage
    func getSuggestedActions(tripId: UUID) async -> [String]
    func getChatHistory(tripId: UUID) async -> [ChatMessage]
}
