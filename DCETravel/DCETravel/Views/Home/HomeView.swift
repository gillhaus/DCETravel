import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var chatText = ""
    @State private var appeared = false

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Concierge chat section
                    conciergeSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    // Hero trip card
                    if let trip = viewModel.upcomingTrip {
                        ConciergeHeroCard(
                            trip: trip,
                            daysUntil: viewModel.daysUntilTrip,
                            bookingsCount: viewModel.tripBookingsCount
                        ) {
                            router.navigate(to: .tripReview(tripId: trip.id))
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                    }

                    // Quick actions
                    quickActionsRow
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    // For You highlights
                    forYouSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    // Inspiration carousel
                    inspirationSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .refreshable {
                await viewModel.loadData(appState: appState)
            }
        }
        .navigationTitle("Travel Concierge")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.navigate(to: .actionsGrid)
                } label: {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DCEColors.navy)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.presentSheet(.profile)
                } label: {
                    Text(appState.currentUser.initials)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [DCEColors.navy, Color(hex: "2D4A7A")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
            }
        }
        .task {
            await viewModel.loadData(appState: appState)
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    // MARK: - Concierge Section

    private var conciergeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("What can I help\nyou plan?")
                    .font(DCEFonts.displayMedium())
                    .foregroundColor(DCEColors.primaryText)

                // Copper accent underline
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            colors: [DCEColors.copper, DCEColors.copper.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 2)
            }
            .padding(.horizontal, 20)

            // Chat input
            Button {
                if let trip = appState.activeTrips.first {
                    router.navigate(to: .chat(tripId: trip.id))
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DCEColors.copper)
                    Text("Ask away, and elevate any trip")
                        .font(DCEFonts.bodyMedium())
                        .foregroundColor(DCEColors.tertiaryText)
                    Spacer()
                    Image(systemName: "mic")
                        .font(.system(size: 16))
                        .foregroundColor(DCEColors.secondaryText)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(DCEColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: DCEColors.navy.opacity(0.06), radius: 8, x: 0, y: 3)
                .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // Suggestion pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    suggestionPill("Flights", icon: "airplane")
                    suggestionPill("Hotels", icon: "building.2")
                    suggestionPill("Restaurants", icon: "fork.knife")
                    suggestionPill("Explore", icon: "map")
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func suggestionPill(_ title: String, icon: String) -> some View {
        Button {
            if let trip = appState.activeTrips.first {
                appState.pendingChatAction = "Help me find \(title.lowercased()) for my trip"
                router.navigate(to: .chat(tripId: trip.id))
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(DCEFonts.labelMedium())
            }
            .foregroundColor(DCEColors.navy)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(DCEColors.cardBackground)
                    .shadow(color: DCEColors.navy.opacity(0.06), radius: 4, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .strokeBorder(DCEColors.navy.opacity(0.12), lineWidth: 1)
            )
        }
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        HStack(spacing: 0) {
            quickAction("Flights", icon: "airplane", category: .flights)
            quickAction("Hotels", icon: "building.2", category: .hotels)
            quickAction("Dining", icon: "fork.knife", category: .restaurants)
            quickAction("Cars", icon: "car.fill", category: .cars)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
    }

    private func quickAction(_ title: String, icon: String, category: SearchCategory) -> some View {
        Button {
            if let trip = appState.activeTrips.first {
                router.navigate(to: .searchResults(tripId: trip.id, category: category))
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DCEColors.navy)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(DCEColors.cardBackground)
                            .shadow(color: DCEColors.navy.opacity(0.08), radius: 6, x: 0, y: 2)
                    )
                Text(title)
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - For You Section

    private var forYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("For You", icon: "heart.fill")

            // Next booking card
            if let booking = viewModel.nextBooking {
                ConciergeHighlightCard(variant: .nextBooking(booking: booking)) {
                    router.navigate(to: .bookingList(tripId: booking.tripId))
                }
            }

            // AI suggestion card
            if let suggestion = viewModel.aiSuggestion {
                ConciergeHighlightCard(variant: .aiSuggestion(title: suggestion.title, subtitle: suggestion.subtitle)) {
                    appState.pendingChatAction = "Tell me more about: \(suggestion.title)"
                    router.navigate(to: .chat(tripId: suggestion.tripId))
                }
            }

            // Points summary card
            ConciergeHighlightCard(
                variant: .pointsSummary(
                    balance: viewModel.formattedPoints,
                    tier: viewModel.membershipTier.rawValue,
                    value: viewModel.formattedPointsValue
                )
            ) {
                if let trip = appState.activeTrips.first {
                    router.navigate(to: .searchResults(tripId: trip.id, category: .points))
                }
            }
        }
    }

    // MARK: - Inspiration Section

    private var inspirationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Inspiration", icon: "globe.americas.fill")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.inspirationDestinations) { destination in
                        DestinationCard(destination: destination, width: 200, height: 260) {
                            if let trip = appState.activeTrips.first {
                                appState.pendingChatAction = "Tell me about \(destination.name), \(destination.country)"
                                router.navigate(to: .chat(tripId: trip.id))
                            }
                        }
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DCEColors.copper)
            Text(title)
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

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
