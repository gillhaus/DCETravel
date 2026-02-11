import SwiftUI

enum ChatItemAction {
    case bookFlight(Flight)
    case bookHotel(Hotel)
    case bookRestaurant(Restaurant)
    case bookCar(CarRental)
    case exploreDest(Destination)
    case selectTheme(ItineraryTheme)
    case viewBooking(Booking)
    case viewLounge
    case viewConfirmation(Booking)
}

struct ChatBubble: View {
    let message: ChatMessage
    let onItemAction: ((ChatItemAction) -> Void)?

    private var isAgent: Bool { message.sender == .agent }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isAgent {
                agentAvatar
            }

            VStack(alignment: isAgent ? .leading : .trailing, spacing: 8) {
                // Text bubble
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(DCEFonts.bodyMedium())
                        .foregroundColor(DCEColors.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(isAgent ? DCEColors.agentBubble : DCEColors.userBubble)
                        .cornerRadius(20)
                        .cornerRadius(isAgent ? 4 : 20, corners: isAgent ? [.topLeft] : [])
                        .cornerRadius(isAgent ? 20 : 4, corners: isAgent ? [] : [.topRight])
                        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
                }

                // Rich content
                if let rich = message.richContent {
                    richContentView(rich)
                }

                // Timestamp
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.tertiaryText)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isAgent ? .leading : .trailing)

            if !isAgent {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: isAgent ? .leading : .trailing)
        .padding(.horizontal, 16)
    }

    private var agentAvatar: some View {
        ZStack {
            Circle()
                .fill(DCEColors.navy)
                .frame(width: 32, height: 32)
            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private func richContentView(_ content: ChatMessage.RichContent) -> some View {
        switch content.type {
        case .image:
            if let url = content.imageURL {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 250, maxHeight: 180)
                            .cornerRadius(12)
                    default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DCEColors.shimmer)
                            .frame(height: 180)
                    }
                }
            }
        case .hotelCard:
            if let hotel = content.hotel {
                MiniHotelCard(hotel: hotel) {
                    onItemAction?(.bookHotel(hotel))
                }
            }
        case .restaurantCard:
            if let restaurant = content.restaurant {
                MiniRestaurantCard(restaurant: restaurant) {
                    onItemAction?(.bookRestaurant(restaurant))
                }
            }
        case .itineraryThemes:
            if let themes = content.itineraryThemes {
                ItineraryThemeCards(themes: themes) { theme in
                    onItemAction?(.selectTheme(theme))
                }
            }
        case .loungeCard:
            LoungeMiniCard {
                onItemAction?(.viewLounge)
            }
        case .flightResults:
            if let flights = content.flights, !flights.isEmpty {
                VStack(spacing: 8) {
                    ForEach(flights) { flight in
                        FlightResultCard(flight: flight) {
                            onItemAction?(.bookFlight(flight))
                        }
                    }
                }
            }
        case .destinationResults:
            if let destinations = content.destinations, !destinations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(destinations.prefix(4)) { dest in
                            Button {
                                onItemAction?(.exploreDest(dest))
                            } label: {
                                MiniDestinationCard(destination: dest)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        case .bookingsList:
            if let bookingList = content.bookings, !bookingList.isEmpty {
                VStack(spacing: 6) {
                    ForEach(bookingList) { booking in
                        Button {
                            onItemAction?(.viewBooking(booking))
                        } label: {
                            BookingRowCard(booking: booking)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        case .bookingConfirmation:
            if let booking = content.booking {
                Button {
                    onItemAction?(.viewConfirmation(booking))
                } label: {
                    BookingConfirmationCard(booking: booking)
                }
                .buttonStyle(.plain)
            }
        case .carRentalResults:
            if let cars = content.carRentals, !cars.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(cars) { car in
                            CarRentalCard(car: car) {
                                onItemAction?(.bookCar(car))
                            }
                        }
                    }
                }
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - New Rich Content Cards

struct FlightResultCard: View {
    let flight: Flight
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(flight.airline) \(flight.flightNumber)")
                        .font(DCEFonts.labelMedium())
                        .foregroundColor(DCEColors.primaryText)
                    Text("\(flight.departureAirport) → \(flight.arrivalAirport)")
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.secondaryText)
                    Text(flight.cabinClass.rawValue)
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.copper)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(Int(flight.price))")
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.primaryText)
                    Text("\(flight.pointsCost.formatted()) pts")
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }
            }
            .padding(12)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct MiniDestinationCard: View {
    let destination: Destination

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: URL(string: destination.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                default:
                    Rectangle().fill(DCEColors.shimmer)
                }
            }
            .frame(width: 120, height: 80)
            .cornerRadius(8)

            Text(destination.name)
                .font(DCEFonts.labelSmall())
                .foregroundColor(DCEColors.primaryText)
            Text(destination.country)
                .font(DCEFonts.caption())
                .foregroundColor(DCEColors.secondaryText)
        }
        .frame(width: 120)
    }
}

struct BookingRowCard: View {
    let booking: Booking

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: booking.type == .flight ? "airplane" : booking.type == .hotel ? "building.2" : "fork.knife")
                .font(.system(size: 14))
                .foregroundColor(DCEColors.navy)
                .frame(width: 28, height: 28)
                .background(DCEColors.navy.opacity(0.1))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(booking.details)
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.primaryText)
                    .lineLimit(1)
                Text(booking.confirmationNumber)
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.secondaryText)
            }

            Spacer()

            Text(booking.status.rawValue)
                .font(DCEFonts.caption())
                .foregroundColor(booking.status == .confirmed ? DCEColors.success : DCEColors.warning)
        }
        .padding(10)
        .background(DCEColors.cardBackground)
        .cornerRadius(10)
    }
}

struct BookingConfirmationCard: View {
    let booking: Booking

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(DCEColors.success)

            Text("Booking Confirmed")
                .font(DCEFonts.labelLarge())
                .foregroundColor(DCEColors.primaryText)

            Text(booking.confirmationNumber)
                .font(DCEFonts.headlineLarge())
                .foregroundColor(DCEColors.navy)

            Text(booking.details)
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(DCEColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// Custom corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
