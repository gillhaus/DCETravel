import SwiftUI

struct TripSuggestionsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = TripSuggestionsViewModel()
    @State private var chatText = ""

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.flights.isEmpty {
                    Spacer()
                    ProgressView()
                        .tint(DCEColors.navy)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Destination pills
                            destinationPicker

                            // Flights
                            if !viewModel.flights.isEmpty {
                                categorySection(
                                    title: "Flights",
                                    icon: "airplane"
                                ) {
                                    flightsRow
                                }
                            }

                            // Hotels
                            if !viewModel.hotels.isEmpty {
                                categorySection(
                                    title: "Hotels",
                                    icon: "building.2"
                                ) {
                                    hotelsRow
                                }
                            }

                            // Car Rentals
                            if !viewModel.carRentals.isEmpty {
                                categorySection(
                                    title: "Cars",
                                    icon: "car.fill"
                                ) {
                                    carsRow
                                }
                            }

                            // Restaurants
                            if !viewModel.restaurants.isEmpty {
                                categorySection(
                                    title: "Restaurants",
                                    icon: "fork.knife"
                                ) {
                                    restaurantsRow
                                }
                            }

                            Spacer(minLength: 100)
                        }
                    }
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
        .navigationTitle("Trip Suggestions")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadDestinations(services: appState.services)
        }
    }

    // MARK: - Destination Picker

    private var destinationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.destinations) { destination in
                    Button {
                        Task {
                            await viewModel.selectDestination(destination, services: appState.services)
                        }
                    } label: {
                        Text(destination.name)
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(
                                viewModel.selectedDestination?.id == destination.id
                                    ? .white : DCEColors.navy
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectedDestination?.id == destination.id
                                    ? DCEColors.navy : DCEColors.navy.opacity(0.08)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    // MARK: - Category Section

    private func categorySection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(DCEColors.navy)
                Text(title)
                    .font(DCEFonts.headlineMedium())
                    .foregroundColor(DCEColors.primaryText)
            }
            .padding(.horizontal, 20)

            content()
        }
    }

    // MARK: - Flights Row

    private var flightsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(viewModel.flights) { flight in
                    MiniFlightCard(flight: flight) {
                        if let trip = appState.activeTrips.first {
                            router.navigate(to: .itemCheckout(tripId: trip.id, item: .flight(flight)))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Hotels Row

    private var hotelsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(viewModel.hotels) { hotel in
                    MiniHotelCard(hotel: hotel) {
                        if let trip = appState.activeTrips.first {
                            router.navigate(to: .itemCheckout(tripId: trip.id, item: .hotel(hotel)))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Cars Row

    private var carsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(viewModel.carRentals) { car in
                    CarRentalCard(car: car) {
                        if let trip = appState.activeTrips.first {
                            router.navigate(to: .itemCheckout(tripId: trip.id, item: .carRental(car)))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Restaurants Row

    private var restaurantsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(viewModel.restaurants) { restaurant in
                    MiniRestaurantCard(restaurant: restaurant) {
                        if let trip = appState.activeTrips.first {
                            router.navigate(to: .itemCheckout(tripId: trip.id, item: .restaurant(restaurant)))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
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

// MARK: - Mini Flight Card (for browse)

struct MiniFlightCard: View {
    let flight: Flight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.system(size: 12))
                        .foregroundColor(DCEColors.navy)
                    Text(flight.airline)
                        .font(DCEFonts.labelMedium())
                        .foregroundColor(DCEColors.secondaryText)
                }

                Text(flight.flightNumber)
                    .font(DCEFonts.headlineSmall())
                    .foregroundColor(DCEColors.primaryText)

                HStack {
                    Text(flight.departureAirport)
                        .font(DCEFonts.labelMedium())
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                    Text(flight.arrivalAirport)
                        .font(DCEFonts.labelMedium())
                }
                .foregroundColor(DCEColors.secondaryText)

                Text(flight.cabinClass.rawValue)
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.secondaryText)

                Divider()

                HStack {
                    Text("$\(Int(flight.price))")
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.primaryText)
                    Spacer()
                    Text("\(flight.pointsCost.formatted()) pts")
                        .font(DCEFonts.labelMedium())
                        .foregroundColor(DCEColors.copper)
                }
            }
            .padding(12)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .frame(width: 220)
    }
}

#Preview {
    NavigationStack {
        TripSuggestionsView()
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
