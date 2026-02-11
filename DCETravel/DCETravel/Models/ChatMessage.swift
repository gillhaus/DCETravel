import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var sender: MessageSender
    var text: String
    var timestamp: Date
    var richContent: RichContent?

    enum MessageSender: String, Codable {
        case user
        case agent
    }

    struct RichContent: Codable {
        var type: RichContentType
        var imageURL: String?
        var hotel: Hotel?
        var restaurant: Restaurant?
        var itineraryThemes: [ItineraryTheme]?
        var booking: Booking?
        var flights: [Flight]?
        var destinations: [Destination]?
        var bookings: [Booking]?
        var carRentals: [CarRental]?
        var linkText: String?
        var linkURL: String?

        init(type: RichContentType, imageURL: String? = nil, hotel: Hotel? = nil,
             restaurant: Restaurant? = nil, itineraryThemes: [ItineraryTheme]? = nil,
             booking: Booking? = nil, flights: [Flight]? = nil,
             destinations: [Destination]? = nil, bookings: [Booking]? = nil,
             carRentals: [CarRental]? = nil, linkText: String? = nil, linkURL: String? = nil) {
            self.type = type
            self.imageURL = imageURL
            self.hotel = hotel
            self.restaurant = restaurant
            self.itineraryThemes = itineraryThemes
            self.booking = booking
            self.flights = flights
            self.destinations = destinations
            self.bookings = bookings
            self.carRentals = carRentals
            self.linkText = linkText
            self.linkURL = linkURL
        }
    }

    enum RichContentType: String, Codable {
        case image
        case hotelCard
        case restaurantCard
        case itineraryThemes
        case bookingConfirmation
        case link
        case loungeCard
        case statusBadge
        case flightResults
        case destinationResults
        case bookingsList
        case carRentalResults
    }
}
