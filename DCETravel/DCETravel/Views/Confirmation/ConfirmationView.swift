import SwiftUI

struct ConfirmationView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var animateContent = false

    private var trip: Trip? {
        appState.activeTrips.first(where: { $0.id == tripId })
    }

    private var latestBooking: Booking? {
        appState.bookings
            .filter { $0.tripId == tripId && $0.status == .confirmed }
            .last
    }

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Logo
                    HStack(spacing: 8) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DCEColors.navy)
                        Text("Travel")
                            .font(DCEFonts.headlineLarge())
                            .foregroundColor(DCEColors.navy)
                    }
                    .padding(.top, 20)
                    .opacity(animateContent ? 1 : 0)

                    // Confirmation headline
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(DCEColors.success)
                            .scaleEffect(animateContent ? 1 : 0.5)

                        Text(confirmationTitle)
                            .font(DCEFonts.displayMedium())
                            .foregroundColor(DCEColors.primaryText)
                            .multilineTextAlignment(.center)

                        if let booking = latestBooking {
                            Text("Confirmation: \(booking.confirmationNumber)")
                                .font(DCEFonts.headlineSmall())
                                .foregroundColor(DCEColors.copper)
                        } else {
                            Text("Buon viaggio!")
                                .font(DCEFonts.displaySmall())
                                .foregroundColor(DCEColors.copper)
                        }

                        Text(confirmationMessage)
                            .font(DCEFonts.bodyMedium())
                            .foregroundColor(DCEColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    // Benefits cards
                    VStack(spacing: 12) {
                        if let booking = latestBooking {
                            if let price = booking.price {
                                BenefitCard(
                                    icon: "star.circle.fill",
                                    iconColor: DCEColors.copper,
                                    title: "Points earned",
                                    detail: "+\(Int(price).formatted()) points from this booking"
                                )
                            }
                            if let points = booking.pointsUsed {
                                BenefitCard(
                                    icon: "star.circle.fill",
                                    iconColor: DCEColors.copper,
                                    title: "Points used",
                                    detail: "\(points.formatted()) points redeemed"
                                )
                            }
                        }

                        BenefitCard(
                            icon: "creditcard.fill",
                            iconColor: DCEColors.navy,
                            title: "Credits applied",
                            detail: "$500 statement credit · $300 annual travel credit"
                        )

                        BenefitCard(
                            icon: "building.2.fill",
                            iconColor: DCEColors.success,
                            title: "Member benefits",
                            detail: "Priority access · Room upgrade when available · Late check-out"
                        )
                    }
                    .padding(.horizontal, 20)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)

                    // See itinerary button
                    Button {
                        router.navigate(to: .onTrip(tripId: tripId))
                    } label: {
                        Text("See itinerary")
                    }
                    .buttonStyle(DCEPrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .opacity(animateContent ? 1 : 0)

                    // Go home button
                    Button {
                        router.goToRoot()
                        router.navigate(to: .home)
                    } label: {
                        Text("Back to home")
                    }
                    .buttonStyle(DCESecondaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.goToRoot()
                    router.navigate(to: .home)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(DCEColors.secondaryText)
                }
            }
        }
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateContent = true
            }
        }
    }

    private var confirmationTitle: String {
        if let trip = trip {
            return "\(trip.name)\nis confirmed."
        }
        return "Booking confirmed!"
    }

    private var confirmationMessage: String {
        if let booking = latestBooking {
            return "Your \(booking.type.rawValue.lowercased()) booking is all set. \(booking.details)"
        }
        return "Get ready for an unforgettable adventure. Your itinerary is set for the perfect getaway."
    }
}

// MARK: - Benefit Card
struct BenefitCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DCEFonts.labelLarge())
                    .foregroundColor(DCEColors.primaryText)
                Text(detail)
                    .font(DCEFonts.bodySmall())
                    .foregroundColor(DCEColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(DCEColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        ConfirmationView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
