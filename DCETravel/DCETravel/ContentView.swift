import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            LanderView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .actionsGrid:
                        ActionsGridView()
                    case .chat(let tripId):
                        ChatView(tripId: tripId)
                    case .checkout(let tripId):
                        CheckoutView(tripId: tripId)
                    case .itemCheckout(let tripId, let item):
                        UnifiedCheckoutView(tripId: tripId, item: item)
                    case .confirmation(let tripId):
                        ConfirmationView(tripId: tripId)
                    case .bookingList(let tripId):
                        BookingListView(tripId: tripId)
                    case .searchResults(let tripId, let category):
                        SearchResultsView(tripId: tripId, category: category)
                    case .onTrip(let tripId):
                        OnTripView(tripId: tripId)
                    case .postTrip:
                        PostTripView()
                    case .tripSuggestions:
                        TripSuggestionsView()
                    case .tripReview(let tripId):
                        TripReviewView(tripId: tripId)
                    }
                }
        }
        .tint(DCEColors.navy)
        .sheet(item: $router.presentedSheet) { sheet in
            switch sheet {
            case .profile:
                ProfileSheetView()
                    .environmentObject(appState)
                    .environmentObject(router)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AppRouter())
}
