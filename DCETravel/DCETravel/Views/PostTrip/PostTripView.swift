import SwiftUI

struct PostTripView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var chatText = ""

    private let quickActions: [(title: String, icon: String)] = [
        ("Trip suggestions", "airplane"),
        ("Maximize points", "star.circle"),
        ("Benefits", "shield.checkered"),
        ("Book restaurants", "fork.knife")
    ]

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Quick action chips
                        QuickActionChipsRow(actions: quickActions) { action in
                            if let trip = appState.activeTrips.first {
                                router.navigate(to: .chat(tripId: trip.id))
                            }
                        }
                        .padding(.top, 8)

                        // Updates section
                        updatesSection

                        // Based on your recent trip
                        recentTripSection

                        Spacer(minLength: 100)
                    }
                }

                // Bottom chat bar
                ChatInputBar(
                    text: $chatText,
                    onSend: {
                        if let trip = appState.activeTrips.first {
                            router.navigate(to: .chat(tripId: trip.id))
                        }
                        chatText = ""
                    },
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
                    router.goToRoot()
                    router.navigate(to: .home)
                } label: {
                    Image(systemName: "clock")
                        .foregroundColor(DCEColors.navy)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {} label: {
                    Image(systemName: "person.circle")
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
    }

    // MARK: - Updates Section
    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Updates")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(MockData.updateAlerts) { alert in
                    UpdateAlertCard(alert: alert) {}
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Recent Trip Recommendations
    private var recentTripSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Based on your recent trip")
                    .font(DCEFonts.headlineMedium())
                    .foregroundColor(DCEColors.primaryText)
                Text("Newly created recommendations for you")
                    .font(DCEFonts.bodySmall())
                    .foregroundColor(DCEColors.secondaryText)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(MockData.destinations.filter { $0.category == .recommended || $0.category == .inspiration }) { destination in
                        DestinationCard(destination: destination) {
                            if let trip = appState.activeTrips.first {
                                router.navigate(to: .chat(tripId: trip.id))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            Button {
                // Suggest more
            } label: {
                Text("Suggest more")
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.copper)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        PostTripView()
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
