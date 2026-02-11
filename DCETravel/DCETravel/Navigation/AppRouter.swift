import SwiftUI

enum BookingItem: Hashable {
    case flight(Flight)
    case hotel(Hotel)
    case carRental(CarRental)
    case restaurant(Restaurant)
}

enum SearchCategory: String, Hashable {
    case flights, hotels, cars, restaurants, points, bookings, destinations

    var title: String {
        switch self {
        case .flights: return "Flights"
        case .hotels: return "Hotels"
        case .cars: return "Car Rentals"
        case .restaurants: return "Restaurants"
        case .points: return "Points & Rewards"
        case .bookings: return "My Bookings"
        case .destinations: return "Destinations"
        }
    }

    var icon: String {
        switch self {
        case .flights: return "airplane"
        case .hotels: return "building.2"
        case .cars: return "car.fill"
        case .restaurants: return "fork.knife"
        case .points: return "star.circle.fill"
        case .bookings: return "list.clipboard"
        case .destinations: return "map"
        }
    }
}

enum AppRoute: Hashable {
    case home
    case actionsGrid
    case chat(tripId: UUID)
    case checkout(tripId: UUID)
    case itemCheckout(tripId: UUID, item: BookingItem)
    case confirmation(tripId: UUID)
    case bookingList(tripId: UUID)
    case searchResults(tripId: UUID, category: SearchCategory)
    case onTrip(tripId: UUID)
    case postTrip
    case tripSuggestions
    case tripReview(tripId: UUID)
}

@MainActor
class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: SheetDestination?

    enum SheetDestination: Identifiable {
        case actionsGrid
        case hotelDetail(hotelId: UUID)
        case tripItinerary(tripId: UUID)

        var id: String {
            switch self {
            case .actionsGrid: return "actionsGrid"
            case .hotelDetail(let id): return "hotel-\(id)"
            case .tripItinerary(let id): return "itinerary-\(id)"
            }
        }
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func goToRoot() {
        path = NavigationPath()
    }

    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
