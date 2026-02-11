import Foundation

class AgentContext {
    let tripId: UUID
    var conversationHistory: [ChatMessage] = []
    var lastDomain: String?
    var lastSearchResults: SearchResults?
    var pendingAction: PendingAction?
    var userPreferences: [String: String] = [:]

    struct SearchResults {
        var hotels: [Hotel]?
        var flights: [Flight]?
        var restaurants: [Restaurant]?
        var carRentals: [CarRental]?
        var destinations: [Destination]?
        var bookings: [Booking]?
    }

    struct PendingAction {
        let type: PendingActionType
        let description: String
        let data: Any?

        enum PendingActionType {
            case bookHotel
            case bookFlight
            case bookRestaurant
            case bookCar
            case cancelBooking
            case modifyBooking
            case selectItinerary
        }
    }

    init(tripId: UUID) {
        self.tripId = tripId
    }

    func addMessage(_ message: ChatMessage) {
        conversationHistory.append(message)
    }

    func setLastSearch(hotels: [Hotel]? = nil, flights: [Flight]? = nil,
                       restaurants: [Restaurant]? = nil, carRentals: [CarRental]? = nil,
                       destinations: [Destination]? = nil, bookings: [Booking]? = nil) {
        var results = lastSearchResults ?? SearchResults()
        if let h = hotels { results.hotels = h }
        if let f = flights { results.flights = f }
        if let r = restaurants { results.restaurants = r }
        if let c = carRentals { results.carRentals = c }
        if let d = destinations { results.destinations = d }
        if let b = bookings { results.bookings = b }
        lastSearchResults = results
    }

    func setPendingAction(_ type: PendingAction.PendingActionType, description: String, data: Any? = nil) {
        pendingAction = PendingAction(type: type, description: description, data: data)
    }

    func clearPendingAction() {
        pendingAction = nil
    }
}
