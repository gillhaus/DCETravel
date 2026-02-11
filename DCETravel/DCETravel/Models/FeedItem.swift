import Foundation

struct FeedItem: Identifiable {
    let id: UUID
    let type: FeedItemType
    let timestamp: Date
    let title: String
    let subtitle: String
    let icon: String
    let action: FeedAction?

    enum FeedItemType: String {
        case tripUpdate
        case aiSuggestion
        case bookingAlert
        case priceAlert
        case pointsUpdate
        case weatherAlert
        case inspiration
    }

    enum FeedAction {
        case openTrip(tripId: UUID)
        case openChat(tripId: UUID, message: String)
        case openSearch(tripId: UUID, category: SearchCategory)
        case openBooking(tripId: UUID)
        case openCheckout(tripId: UUID, item: BookingItem)
    }
}
