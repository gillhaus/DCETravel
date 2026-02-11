import SwiftUI

struct BookingListView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var isLoading = false

    private var trip: Trip? {
        appState.activeTrips.first(where: { $0.id == tripId })
    }

    private var tripBookings: [Booking] {
        appState.bookings.filter { $0.tripId == tripId && $0.status != .cancelled }
    }

    private var cancelledBookings: [Booking] {
        appState.bookings.filter { $0.tripId == tripId && $0.status == .cancelled }
    }

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            if tripBookings.isEmpty && cancelledBookings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "ticket")
                        .font(.system(size: 48))
                        .foregroundColor(DCEColors.secondaryText)
                    Text("No bookings yet")
                        .font(DCEFonts.headlineMedium())
                        .foregroundColor(DCEColors.primaryText)
                    Text("Start browsing to book flights, hotels, and more.")
                        .font(DCEFonts.bodyMedium())
                        .foregroundColor(DCEColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Active bookings grouped by type
                        if !tripBookings.isEmpty {
                            bookingGroup("Flights", icon: "airplane",
                                        bookings: tripBookings.filter { $0.type == .flight })
                            bookingGroup("Hotels", icon: "building.2",
                                        bookings: tripBookings.filter { $0.type == .hotel })
                            bookingGroup("Car Rentals", icon: "car.fill",
                                        bookings: tripBookings.filter { $0.type == .carRental })
                            bookingGroup("Restaurants", icon: "fork.knife",
                                        bookings: tripBookings.filter { $0.type == .restaurant })
                        }

                        // Cancelled bookings
                        if !cancelledBookings.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Cancelled")
                                    .font(DCEFonts.headlineMedium())
                                    .foregroundColor(DCEColors.secondaryText)
                                    .padding(.horizontal, 20)

                                ForEach(cancelledBookings) { booking in
                                    bookingRow(booking, isCancelled: true)
                                }
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                }
            }
        }
        .navigationTitle("Bookings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadBookings()
        }
    }

    @ViewBuilder
    private func bookingGroup(_ title: String, icon: String, bookings: [Booking]) -> some View {
        if !bookings.isEmpty {
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

                ForEach(bookings) { booking in
                    bookingRow(booking, isCancelled: false)
                }
            }
        }
    }

    private func bookingRow(_ booking: Booking, isCancelled: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForType(booking.type))
                .font(.system(size: 16))
                .foregroundColor(isCancelled ? DCEColors.secondaryText : DCEColors.navy)
                .frame(width: 36, height: 36)
                .background(isCancelled ? DCEColors.secondaryText.opacity(0.1) : DCEColors.navy.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(booking.details)
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(isCancelled ? DCEColors.secondaryText : DCEColors.primaryText)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(booking.confirmationNumber)
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                    if let price = booking.price {
                        Text("$\(Int(price))")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                    }
                    if let points = booking.pointsUsed {
                        Text("\(points.formatted()) pts")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.copper)
                    }
                }
            }

            Spacer()

            if !isCancelled {
                Button {
                    cancelBooking(booking)
                } label: {
                    Text("Cancel")
                        .font(DCEFonts.caption())
                        .foregroundColor(.red)
                }
            } else {
                Text("Cancelled")
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.secondaryText)
            }
        }
        .padding(14)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
        .opacity(isCancelled ? 0.6 : 1.0)
    }

    private func iconForType(_ type: Booking.BookingType) -> String {
        switch type {
        case .flight: return "airplane"
        case .hotel: return "building.2"
        case .restaurant: return "fork.knife"
        case .carRental: return "car.fill"
        case .lounge: return "airplane.departure"
        case .activity: return "ticket"
        }
    }

    private func loadBookings() async {
        isLoading = true
        let allBookings = await appState.services.bookings.getBookings()
        appState.bookings = allBookings
        isLoading = false
    }

    private func cancelBooking(_ booking: Booking) {
        Task {
            let success = await appState.services.bookings.cancelBooking(id: booking.id)
            if success {
                if let idx = appState.bookings.firstIndex(where: { $0.id == booking.id }) {
                    appState.bookings[idx].status = .cancelled
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BookingListView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
