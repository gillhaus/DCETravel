import SwiftUI

@MainActor
class NavigationBridge: ObservableObject {
    weak var router: AppRouter?
    weak var appState: AppState?

    @Published var pendingNavigation: AppRoute?

    func navigate(to route: AppRoute) {
        router?.navigate(to: route)
    }

    func showSearchResults(tripId: UUID, category: SearchCategory) {
        navigate(to: .searchResults(tripId: tripId, category: category))
    }

    func showTripOverview(tripId: UUID) {
        navigate(to: .tripReview(tripId: tripId))
    }

    func showCheckout(tripId: UUID, item: BookingItem) {
        navigate(to: .itemCheckout(tripId: tripId, item: item))
    }

    func setPendingNavigation(_ route: AppRoute) {
        pendingNavigation = route
    }

    func consumePendingNavigation() -> AppRoute? {
        let nav = pendingNavigation
        pendingNavigation = nil
        return nav
    }
}
