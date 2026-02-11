import SwiftUI

struct TripReviewView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = TripSuggestionsViewModel()
    @State private var chatText = ""

    private var trip: Trip? {
        appState.activeTrips.first(where: { $0.id == tripId })
            ?? appState.completedTrips.first(where: { $0.id == tripId })
    }

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if let trip = trip {
                    if viewModel.isLoading && viewModel.flights.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(DCEColors.navy)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 24) {
                                // Trip header
                                tripHeader(trip)

                                // Existing bookings
                                if !appState.bookings.isEmpty {
                                    existingBookingsSection(trip)
                                }

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
                } else {
                    Spacer()
                    Text("Trip not found")
                        .font(DCEFonts.bodyMedium())
                        .foregroundColor(DCEColors.secondaryText)
                    Spacer()
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
        .navigationTitle("Trip Review")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let trip = trip {
                await viewModel.loadForTrip(trip, services: appState.services)
            }
        }
    }

    // MARK: - Trip Header

    private func tripHeader(_ trip: Trip) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: trip.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(DCEColors.shimmer)
                    }
                }
                .frame(height: 180)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(DCEFonts.headlineLarge())
                        .foregroundColor(.white)
                    HStack(spacing: 12) {
                        Label(trip.dateRangeText, systemImage: "calendar")
                        Label("\(trip.travelers.count) travelers", systemImage: "person.2")
                    }
                    .font(DCEFonts.caption())
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(16)
            }
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
    }

    // MARK: - Existing Bookings

    private func existingBookingsSection(_ trip: Trip) -> some View {
        let tripBookings = appState.bookings.filter { $0.tripId == trip.id }
        return Group {
            if !tripBookings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DCEColors.success)
                        Text("Booked")
                            .font(DCEFonts.headlineMedium())
                            .foregroundColor(DCEColors.primaryText)
                    }
                    .padding(.horizontal, 20)

                    VStack(spacing: 8) {
                        ForEach(tripBookings) { booking in
                            HStack {
                                Image(systemName: iconForBookingType(booking.type))
                                    .foregroundColor(DCEColors.success)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(booking.details)
                                        .font(DCEFonts.labelMedium())
                                        .foregroundColor(DCEColors.primaryText)
                                    Text(booking.confirmationNumber)
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(DCEColors.success)
                            }
                            .padding(12)
                            .background(DCEColors.success.opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func iconForBookingType(_ type: Booking.BookingType) -> String {
        switch type {
        case .flight: return "airplane"
        case .hotel: return "building.2"
        case .restaurant: return "fork.knife"
        case .carRental: return "car.fill"
        case .lounge: return "airplane.departure"
        case .activity: return "ticket"
        }
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
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .flight(flight)))
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
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .hotel(hotel)))
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
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .carRental(car)))
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
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .restaurant(restaurant)))
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

#Preview {
    NavigationStack {
        TripReviewView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
