import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var feedViewModel = FeedViewModel()
    @State private var chatText = ""

    private struct PillTab: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
    }

    private let pillTabs: [PillTab] = [
        PillTab(title: "Trips", icon: "airplane"),
        PillTab(title: "Search", icon: "magnifyingglass"),
        PillTab(title: "Points", icon: "star.circle.fill")
    ]

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Horizontal pill bar
                        pillBar

                        // Social feed
                        feedSection

                        // Inspiration section
                        inspirationSection

                        Spacer(minLength: 100)
                    }
                }
                .refreshable {
                    await feedViewModel.loadFeed(appState: appState)
                }

                // Bottom chat bar
                ChatInputBar(
                    text: $chatText,
                    onSend: { sendMessage() },
                    onCamera: {},
                    onMic: {}
                )
            }
        }
        .navigationTitle("Travel Concierge")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.navigate(to: .actionsGrid)
                } label: {
                    Image(systemName: "clock")
                        .foregroundColor(DCEColors.navy)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // profile action
                } label: {
                    Image(systemName: "person.circle")
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
        .task {
            await feedViewModel.loadFeed(appState: appState)
        }
    }

    // MARK: - Pill Bar

    private var pillBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(pillTabs) { tab in
                    Button {
                        handlePillTap(tab)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 13, weight: .medium))
                            Text(tab.title)
                                .font(DCEFonts.labelMedium())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(DCEColors.navy)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    // MARK: - Feed Section

    private var feedSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(feedViewModel.feedItems) { item in
                FeedCard(item: item) { action in
                    handleFeedAction(action)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Inspiration Section

    private var inspirationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Inspiration for your next trip")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    let destinations = appState.inspirationDestinations.isEmpty
                        ? MockData.destinations
                        : appState.inspirationDestinations
                    ForEach(destinations) { destination in
                        DestinationCard(destination: destination) {
                            if let trip = appState.activeTrips.first {
                                appState.pendingChatAction = "Tell me about \(destination.name), \(destination.country)"
                                router.navigate(to: .chat(tripId: trip.id))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Actions

    private func handlePillTap(_ tab: PillTab) {
        switch tab.title {
        case "Trips":
            router.navigate(to: .tripSuggestions)
        case "Search":
            if let trip = appState.activeTrips.first {
                router.navigate(to: .searchResults(tripId: trip.id, category: .flights))
            }
        case "Points":
            if let trip = appState.activeTrips.first {
                router.navigate(to: .searchResults(tripId: trip.id, category: .points))
            }
        default:
            break
        }
    }

    private func handleFeedAction(_ action: FeedItem.FeedAction) {
        switch action {
        case .openTrip(let tripId):
            router.navigate(to: .tripReview(tripId: tripId))
        case .openChat(let tripId, let message):
            appState.pendingChatAction = message
            router.navigate(to: .chat(tripId: tripId))
        case .openSearch(let tripId, let category):
            router.navigate(to: .searchResults(tripId: tripId, category: category))
        case .openBooking(let tripId):
            router.navigate(to: .bookingList(tripId: tripId))
        case .openCheckout(let tripId, let item):
            router.navigate(to: .itemCheckout(tripId: tripId, item: item))
        }
    }

    private func sendMessage() {
        guard !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if let trip = appState.activeTrips.first {
            appState.pendingChatAction = chatText
            router.navigate(to: .chat(tripId: trip.id))
        }
        chatText = ""
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
