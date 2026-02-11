import SwiftUI

struct SearchResultsView: View {
    let tripId: UUID
    let category: SearchCategory
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var chatVM = ChatViewModel()

    @State private var flights: [Flight] = []
    @State private var hotels: [Hotel] = []
    @State private var cars: [CarRental] = []
    @State private var restaurants: [Restaurant] = []
    @State private var pointsBalance: Int = 0
    @State private var pointsValue: Double = 0
    @State private var bookingsList: [Booking] = []
    @State private var destinations: [Destination] = []
    @State private var isLoading = true
    @State private var chatText = ""
    @State private var showChat = false

    private var currentTrip: Trip? {
        appState.activeTrips.first { $0.id == tripId }
    }

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Category header
                            categoryHeader

                            // Results
                            if isLoading {
                                loadingPlaceholders
                            } else {
                                resultsContent
                            }

                            // Inline chat section
                            if !chatVM.messages.isEmpty {
                                chatSection
                                    .id("chatAnchor")
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: chatVM.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("chatAnchor", anchor: .bottom)
                        }
                    }
                }

                // Chat input bar
                ChatInputBar(
                    text: $chatText,
                    placeholder: "Ask about \(category.title.lowercased())...",
                    onSend: { sendChatMessage() }
                )
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .chat(tripId: tripId))
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
        .task {
            async let r: () = loadResults()
            async let c: () = chatVM.loadChat(tripId: tripId, services: appState.services, appState: appState, showGreeting: false)
            _ = await (r, c)
        }
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: category.icon)
                .font(.system(size: 20))
                .foregroundColor(DCEColors.navy)
                .frame(width: 36, height: 36)
                .background(DCEColors.navy.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                if let trip = currentTrip {
                    Text(trip.destination)
                        .font(DCEFonts.headlineMedium())
                        .foregroundColor(DCEColors.primaryText)
                    Text(trip.dateRangeText)
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }
            }

            Spacer()

            if !isLoading {
                Text(resultCountText)
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(DCEColors.navy.opacity(0.08))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
    }

    private var resultCountText: String {
        switch category {
        case .flights: return "\(flights.count) found"
        case .hotels: return "\(hotels.count) found"
        case .cars: return "\(cars.count) found"
        case .restaurants: return "\(restaurants.count) found"
        case .points: return ""
        case .bookings: return "\(bookingsList.count) total"
        case .destinations: return "\(destinations.count) places"
        }
    }

    // MARK: - Loading

    private var loadingPlaceholders: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(DCEColors.shimmer)
                    .frame(height: 120)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Results Content

    @ViewBuilder
    private var resultsContent: some View {
        switch category {
        case .flights:
            flightsResults
        case .hotels:
            hotelsResults
        case .cars:
            carsResults
        case .restaurants:
            restaurantsResults
        case .points:
            pointsResults
        case .bookings:
            bookingsResults
        case .destinations:
            destinationsResults
        }
    }

    // MARK: - Flights

    private var flightsResults: some View {
        VStack(spacing: 12) {
            if flights.isEmpty {
                emptyState(message: "No flights found for this route.", suggestion: "Try different dates or destinations.")
            } else {
                ForEach(flights) { flight in
                    Button {
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .flight(flight)))
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
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

                                HStack(spacing: 6) {
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
                                    .foregroundColor(DCEColors.copper)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(Int(flight.price))")
                                    .font(DCEFonts.headlineMedium())
                                    .foregroundColor(DCEColors.primaryText)
                                Text("\(flight.pointsCost.formatted()) pts")
                                    .font(DCEFonts.labelSmall())
                                    .foregroundColor(DCEColors.copper)

                                Text("Select")
                                    .font(DCEFonts.labelSmall())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(DCEColors.navy)
                                    .cornerRadius(14)
                            }
                        }
                        .padding(16)
                        .background(DCEColors.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Hotels

    private var hotelsResults: some View {
        VStack(spacing: 14) {
            if hotels.isEmpty {
                emptyState(message: "No hotels found.", suggestion: "Try a different destination.")
            } else {
                ForEach(hotels) { hotel in
                    Button {
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .hotel(hotel)))
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: URL(string: hotel.imageURLs.first ?? "")) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Rectangle().fill(DCEColors.shimmer)
                                }
                            }
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            .clipped()

                            VStack(alignment: .leading, spacing: 6) {
                                if let tier = hotel.tier {
                                    Text(tier.rawValue)
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.copper)
                                }

                                Text(hotel.name)
                                    .font(DCEFonts.headlineSmall())
                                    .foregroundColor(DCEColors.primaryText)
                                    .lineLimit(2)

                                HStack(spacing: 4) {
                                    ForEach(0..<hotel.starRating, id: \.self) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 9))
                                            .foregroundColor(DCEColors.copper)
                                    }
                                    Text("\(hotel.userRating, specifier: "%.1f")")
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.secondaryText)
                                }

                                HStack {
                                    Text("$\(Int(hotel.totalPrice))")
                                        .font(DCEFonts.labelLarge())
                                        .foregroundColor(DCEColors.primaryText)
                                    Text("/ \(hotel.pointsCost.formatted()) pts")
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.copper)
                                    Spacer()
                                    Text("Select")
                                        .font(DCEFonts.labelSmall())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(DCEColors.navy)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(12)
                        .background(DCEColors.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Cars

    private var carsResults: some View {
        VStack(spacing: 14) {
            if cars.isEmpty {
                emptyState(message: "No car rentals found.", suggestion: "Try a different location.")
            } else {
                ForEach(cars) { car in
                    Button {
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .carRental(car)))
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: URL(string: car.imageURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Rectangle().fill(DCEColors.shimmer)
                                        .overlay(
                                            Image(systemName: "car.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(DCEColors.tertiaryText)
                                        )
                                }
                            }
                            .frame(width: 100, height: 90)
                            .cornerRadius(10)
                            .clipped()

                            VStack(alignment: .leading, spacing: 6) {
                                Text(car.carType.rawValue)
                                    .font(DCEFonts.caption())
                                    .foregroundColor(DCEColors.navy)

                                Text("\(car.company) \(car.model)")
                                    .font(DCEFonts.headlineSmall())
                                    .foregroundColor(DCEColors.primaryText)

                                Text("\(car.seating) seats")
                                    .font(DCEFonts.caption())
                                    .foregroundColor(DCEColors.secondaryText)

                                HStack {
                                    Text("$\(Int(car.pricePerDay))/day")
                                        .font(DCEFonts.labelLarge())
                                        .foregroundColor(DCEColors.primaryText)
                                    Text("/ \(car.pointsCost.formatted()) pts")
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.copper)
                                    Spacer()
                                    Text("Select")
                                        .font(DCEFonts.labelSmall())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(DCEColors.navy)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(12)
                        .background(DCEColors.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Restaurants

    private var restaurantsResults: some View {
        VStack(spacing: 14) {
            if restaurants.isEmpty {
                emptyState(message: "No restaurants found.", suggestion: "Try a different cuisine or area.")
            } else {
                ForEach(restaurants) { restaurant in
                    Button {
                        router.navigate(to: .itemCheckout(tripId: tripId, item: .restaurant(restaurant)))
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: URL(string: restaurant.imageURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Rectangle().fill(DCEColors.shimmer)
                                }
                            }
                            .frame(width: 100, height: 90)
                            .cornerRadius(10)
                            .clipped()

                            VStack(alignment: .leading, spacing: 6) {
                                Text(restaurant.cuisine)
                                    .font(DCEFonts.caption())
                                    .foregroundColor(DCEColors.copper)

                                Text(restaurant.name)
                                    .font(DCEFonts.headlineSmall())
                                    .foregroundColor(DCEColors.primaryText)

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(DCEColors.copper)
                                    Text("\(restaurant.rating, specifier: "%.1f")")
                                        .font(DCEFonts.caption())
                                    Text(restaurant.priceLevel)
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.secondaryText)
                                }

                                HStack {
                                    Text(restaurant.location)
                                        .font(DCEFonts.caption())
                                        .foregroundColor(DCEColors.secondaryText)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("Reserve")
                                        .font(DCEFonts.labelSmall())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(DCEColors.navy)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding(12)
                        .background(DCEColors.cardBackground)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Points

    private var pointsResults: some View {
        VStack(spacing: 16) {
            // Balance card
            VStack(spacing: 12) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(DCEColors.copper)

                Text("\(pointsBalance.formatted())")
                    .font(DCEFonts.headlineLarge())
                    .foregroundColor(DCEColors.primaryText)
                Text("Points Balance")
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.secondaryText)

                Divider().padding(.horizontal, 40)

                Text("$\(String(format: "%.0f", pointsValue)) estimated value")
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.copper)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)

            // Benefits
            VStack(alignment: .leading, spacing: 12) {
                Text("Sapphire Reserve Benefits")
                    .font(DCEFonts.headlineSmall())
                    .foregroundColor(DCEColors.primaryText)

                benefitRow(icon: "building.2", text: "33% Points Boost on hotel bookings")
                benefitRow(icon: "airplane.departure", text: "Airport lounge access worldwide")
                benefitRow(icon: "person.badge.shield.checkmark", text: "Priority boarding on partner airlines")
                benefitRow(icon: "arrow.up.circle", text: "Complimentary room upgrades")
                benefitRow(icon: "dollarsign.circle", text: "$500 statement credit + $300 travel credit")
            }
            .padding(16)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(DCEColors.navy)
                .frame(width: 28)
            Text(text)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
        }
    }

    // MARK: - Bookings

    private var bookingsResults: some View {
        VStack(spacing: 10) {
            if bookingsList.isEmpty {
                emptyState(message: "No bookings yet.", suggestion: "Start browsing flights and hotels to book your trip!")
            } else {
                ForEach(bookingsList) { booking in
                    HStack(spacing: 12) {
                        Image(systemName: bookingIcon(for: booking))
                            .font(.system(size: 16))
                            .foregroundColor(DCEColors.navy)
                            .frame(width: 36, height: 36)
                            .background(DCEColors.navy.opacity(0.1))
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(booking.details)
                                .font(DCEFonts.labelMedium())
                                .foregroundColor(DCEColors.primaryText)
                                .lineLimit(1)
                            Text(booking.confirmationNumber)
                                .font(DCEFonts.caption())
                                .foregroundColor(DCEColors.secondaryText)
                        }

                        Spacer()

                        Text(booking.status.rawValue)
                            .font(DCEFonts.labelSmall())
                            .foregroundColor(booking.status == .confirmed ? DCEColors.success : DCEColors.warning)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                (booking.status == .confirmed ? DCEColors.success : DCEColors.warning)
                                    .opacity(0.1)
                            )
                            .cornerRadius(8)
                    }
                    .padding(14)
                    .background(DCEColors.cardBackground)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func bookingIcon(for booking: Booking) -> String {
        switch booking.type {
        case .flight: return "airplane"
        case .hotel: return "building.2"
        case .carRental: return "car.fill"
        case .restaurant: return "fork.knife"
        default: return "doc.text"
        }
    }

    // MARK: - Destinations

    private var destinationsResults: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(destinations) { dest in
                Button {
                    chatText = "Search flights and hotels for \(dest.name)"
                    sendChatMessage()
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        AsyncImage(url: URL(string: dest.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fill)
                            default:
                                Rectangle().fill(DCEColors.shimmer)
                            }
                        }
                        .frame(height: 100)
                        .cornerRadius(10)
                        .clipped()

                        Text(dest.name)
                            .font(DCEFonts.headlineSmall())
                            .foregroundColor(DCEColors.primaryText)

                        Text(dest.country)
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)

                        HStack(spacing: 4) {
                            ForEach(dest.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(DCEFonts.caption())
                                    .foregroundColor(DCEColors.navy)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(DCEColors.navy.opacity(0.08))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(10)
                    .background(DCEColors.cardBackground)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Chat Section

    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 14))
                    .foregroundColor(DCEColors.navy)
                Text("Concierge Chat")
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.navy)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Divider().padding(.horizontal, 20)

            LazyVStack(spacing: 12) {
                ForEach(chatVM.messages) { message in
                    ChatBubble(message: message) { action in
                        handleItemAction(action)
                    }
                }

                if chatVM.isTyping {
                    HStack(alignment: .top, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(DCEColors.navy)
                                .frame(width: 32, height: 32)
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        TypingIndicator()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Empty State

    private func emptyState(message: String, suggestion: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundColor(DCEColors.tertiaryText)
            Text(message)
                .font(DCEFonts.labelMedium())
                .foregroundColor(DCEColors.primaryText)
            Text(suggestion)
                .font(DCEFonts.caption())
                .foregroundColor(DCEColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Actions

    private func sendChatMessage() {
        guard !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = chatText
        chatText = ""
        Task {
            await chatVM.sendMessage(text, tripId: tripId)
        }
    }

    private func handleItemAction(_ action: ChatItemAction) {
        switch action {
        case .bookFlight(let flight):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .flight(flight)))
        case .bookHotel(let hotel):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .hotel(hotel)))
        case .bookRestaurant(let restaurant):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .restaurant(restaurant)))
        case .bookCar(let car):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .carRental(car)))
        case .exploreDest(let dest):
            chatText = "Search flights and hotels for \(dest.name)"
            sendChatMessage()
        case .selectTheme(let theme):
            chatText = "Plan a \(theme.title) trip"
            sendChatMessage()
        case .viewBooking(let booking):
            chatText = "Tell me about booking \(booking.confirmationNumber)"
            sendChatMessage()
        case .viewLounge:
            chatText = "Tell me about lounge access"
            sendChatMessage()
        case .viewConfirmation:
            router.navigate(to: .confirmation(tripId: tripId))
        }
    }

    // MARK: - Load Results

    private func loadResults() async {
        guard let trip = currentTrip else { isLoading = false; return }

        switch category {
        case .flights:
            flights = await appState.services.flights.searchFlights(from: "LAX", to: trip.destination, date: trip.startDate)
        case .hotels:
            hotels = await appState.services.hotels.searchHotels(destination: trip.destination, checkIn: trip.startDate, checkOut: trip.endDate)
        case .cars:
            cars = await appState.services.carRentals.searchCars(location: trip.destination, pickupDate: trip.startDate, dropoffDate: trip.endDate)
        case .restaurants:
            restaurants = await appState.services.restaurants.searchRestaurants(location: trip.destination, cuisine: nil)
        case .points:
            pointsBalance = await appState.services.points.getBalance()
            pointsValue = await appState.services.points.calculateValue(points: pointsBalance)
        case .bookings:
            bookingsList = await appState.services.bookings.getBookings(tripId: tripId)
        case .destinations:
            destinations = await appState.services.travel.getInspiration()
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        SearchResultsView(tripId: UUID(), category: .flights)
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
