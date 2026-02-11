import SwiftUI

struct UnifiedCheckoutView: View {
    let tripId: UUID
    let item: BookingItem
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var payWithPoints = false
    @State private var isProcessing = false

    private var trip: Trip? {
        appState.activeTrips.first(where: { $0.id == tripId })
    }

    private var itemPrice: Double {
        switch item {
        case .flight(let f): return f.price
        case .hotel(let h): return h.totalPrice
        case .carRental(let c): return c.totalPrice
        case .restaurant: return 150.0 // estimated per person
        }
    }

    private var itemPointsCost: Int {
        switch item {
        case .flight(let f): return f.pointsCost
        case .hotel(let h): return h.pointsCost
        case .carRental(let c): return c.pointsCost
        case .restaurant: return 8_000
        }
    }

    private var taxes: Double { itemPrice * 0.10 }
    private var total: Double { itemPrice + taxes }
    private var pointsEarned: Int { Int(itemPrice) }

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Item summary
                    itemSummarySection

                    // Trip & Travelers
                    tripInfoSection

                    // Payment method
                    paymentMethodSection

                    // Card details (when paying with card)
                    if !payWithPoints {
                        cardDetailsSection
                    }

                    // Price breakdown
                    priceBreakdownSection

                    // Confirm button
                    Button {
                        confirmBooking()
                    } label: {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Confirm Booking")
                        }
                    }
                    .buttonStyle(DCEPrimaryButtonStyle())
                    .disabled(isProcessing)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Item Summary

    private var itemSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Booking Summary")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)

            switch item {
            case .flight(let flight):
                flightSummary(flight)
            case .hotel(let hotel):
                hotelSummary(hotel)
            case .carRental(let car):
                carSummary(car)
            case .restaurant(let restaurant):
                restaurantSummary(restaurant)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func flightSummary(_ flight: Flight) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(DCEColors.navy)
                Text("\(flight.airline) \(flight.flightNumber)")
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.primaryText)
            }
            HStack(spacing: 8) {
                Text(flight.departureAirport)
                    .font(DCEFonts.headlineSmall())
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                Text(flight.arrivalAirport)
                    .font(DCEFonts.headlineSmall())
            }
            .foregroundColor(DCEColors.primaryText)
            HStack {
                Text(flight.cabinClass.rawValue)
                Spacer()
                Text(flight.durationText)
            }
            .font(DCEFonts.bodySmall())
            .foregroundColor(DCEColors.secondaryText)
        }
        .padding(16)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
    }

    private func hotelSummary(_ hotel: Hotel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "building.2")
                    .foregroundColor(DCEColors.navy)
                Text(hotel.name)
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.primaryText)
            }
            Text(hotel.location)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<hotel.starRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(DCEColors.copper)
                    }
                }
                Spacer()
                if let tier = hotel.tier {
                    Text(tier.rawValue)
                        .font(DCEFonts.caption())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(DCEColors.navy)
                        .cornerRadius(4)
                }
            }
            Text("$\(Int(hotel.pricePerNight))/night")
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
        }
        .padding(16)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
    }

    private func carSummary(_ car: CarRental) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(DCEColors.navy)
                Text("\(car.company) - \(car.model)")
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.primaryText)
            }
            Text(car.carType.rawValue)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
            Text(car.pickupLocation)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
            Text("$\(Int(car.pricePerDay))/day")
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
        }
        .padding(16)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
    }

    private func restaurantSummary(_ restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(DCEColors.navy)
                Text(restaurant.name)
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.primaryText)
            }
            Text(restaurant.cuisine)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
            HStack {
                Text(restaurant.location)
                Spacer()
                Text(restaurant.priceLevel)
            }
            .font(DCEFonts.bodySmall())
            .foregroundColor(DCEColors.secondaryText)
        }
        .padding(16)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Trip Info

    private var tripInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trip & Travelers")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)

            VStack(alignment: .leading, spacing: 6) {
                if let trip = trip {
                    Text(trip.name)
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.primaryText)
                    Text(trip.travelers.joined(separator: ", "))
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.secondaryText)
                    Text(trip.dateRangeText)
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.secondaryText)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Payment Method

    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)

            // Points option
            Button {
                payWithPoints = true
            } label: {
                HStack {
                    Image(systemName: payWithPoints ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(DCEColors.navy)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pay with Points")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.primaryText)
                        Text("\(itemPointsCost.formatted()) points")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.copper)
                    }
                    Spacer()
                }
                .padding(12)
                .background(payWithPoints ? DCEColors.navy.opacity(0.08) : DCEColors.cardBackground)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            // Card option
            Button {
                payWithPoints = false
            } label: {
                HStack {
                    Image(systemName: payWithPoints ? "circle" : "largecircle.fill.circle")
                        .foregroundColor(DCEColors.navy)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pay with Card")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.primaryText)
                        Text("Chase Sapphire Reserve")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                    }
                    Spacer()
                }
                .padding(12)
                .background(!payWithPoints ? DCEColors.navy.opacity(0.08) : DCEColors.cardBackground)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Card Details

    private var cardDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Details")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(DCEColors.navy)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Victoria Chen")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.primaryText)
                        Text("•••• •••• •••• 4242")
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.secondaryText)
                    }
                    Spacer()
                    Text("Sapphire Reserve")
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.copper)
                }
            }
            .padding(16)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Price Breakdown

    private var priceBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
                .padding(.horizontal, 20)

            VStack(spacing: 8) {
                if payWithPoints {
                    priceRow("Points cost", value: "\(itemPointsCost.formatted()) pts")
                } else {
                    priceRow("Subtotal", value: String(format: "$%.2f", itemPrice))
                    priceRow("Taxes & fees", value: String(format: "$%.2f", taxes))
                    priceRow("Points earned", value: "+\(pointsEarned.formatted())", highlight: true)
                    Divider()
                    HStack {
                        Text("Total")
                            .font(DCEFonts.headlineMedium())
                            .foregroundColor(DCEColors.primaryText)
                        Spacer()
                        Text(String(format: "$%.2f", total))
                            .font(DCEFonts.headlineMedium())
                            .foregroundColor(DCEColors.primaryText)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func priceRow(_ label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(DCEFonts.bodyMedium())
                .foregroundColor(DCEColors.secondaryText)
            Spacer()
            Text(value)
                .font(DCEFonts.labelMedium())
                .foregroundColor(highlight ? DCEColors.success : DCEColors.primaryText)
        }
    }

    // MARK: - Actions

    private func confirmBooking() {
        isProcessing = true

        Task {
            switch item {
            case .flight(let flight):
                let booking = await appState.services.flights.bookFlight(flight)
                appState.bookings.append(booking)
            case .hotel(let hotel):
                let guests = trip?.travelers ?? ["Victoria"]
                let booking = await appState.services.hotels.bookHotel(hotel, guests: guests)
                appState.bookings.append(booking)
            case .carRental(let car):
                let booking = await appState.services.carRentals.bookCar(car)
                appState.bookings.append(booking)
            case .restaurant(let restaurant):
                let guests = trip?.travelers.count ?? 2
                let booking = await appState.services.restaurants.bookTable(
                    restaurantId: restaurant.id, date: Date(), guests: guests)
                appState.bookings.append(booking)
            }

            isProcessing = false

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            router.navigate(to: .confirmation(tripId: tripId))
        }
    }
}

#Preview {
    NavigationStack {
        UnifiedCheckoutView(
            tripId: UUID(),
            item: .flight(Flight(
                id: UUID(), airline: "United", flightNumber: "UA 412",
                departureAirport: "LAX", arrivalAirport: "FCO",
                departureTime: Date(), arrivalTime: Date().addingTimeInterval(36000),
                price: 2850, pointsCost: 85000, cabinClass: .business, status: .scheduled
            ))
        )
        .environmentObject(AppState())
        .environmentObject(AppRouter())
    }
}
