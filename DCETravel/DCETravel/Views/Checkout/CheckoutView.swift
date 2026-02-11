import SwiftUI

struct CheckoutView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var isLoading = false
    @State private var selectedHotel: Hotel?
    @State private var showApproveAnimation = false

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Booking info
                    bookingInfoSection

                    // Selected for you section
                    selectedSection

                    // Hotel card
                    if let hotel = selectedHotel ?? MockData.hotels.first {
                        HotelCard(
                            hotel: hotel,
                            nightCount: currentTrip?.nightCount ?? 5,
                            showPointsBoost: true
                        ) {
                            // Hotel detail tap
                        }
                        .padding(.horizontal, 20)
                    }

                    // Suggest other options
                    Button {
                        // Show alternatives
                    } label: {
                        Text("Suggest other options")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.copper)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 4)

                    // Approve button
                    Button {
                        approveHotel()
                    } label: {
                        Text("Approve selected hotel")
                    }
                    .buttonStyle(DCEPrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Hotel in Rome")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadHotel()
        }
    }

    private var currentTrip: Trip? {
        appState.activeTrips.first { $0.id == tripId }
    }

    // MARK: - Booking Info Section
    private var bookingInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Booking for")
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.secondaryText)
                    Text(currentTrip?.travelers.joined(separator: ", ") ?? "Victoria, Jaclyn, Daphne & Harper")
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.primaryText)
                        .lineLimit(1)
                }
                Spacer()
                Button("Change") {}
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.copper)
            }
            .padding(16)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Selected Section
    private var selectedSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected for you")
                .font(DCEFonts.headlineMedium())
                .foregroundColor(DCEColors.primaryText)
            Text("Based on your preferences")
                .font(DCEFonts.bodySmall())
                .foregroundColor(DCEColors.secondaryText)
        }
        .padding(.horizontal, 20)
    }

    private func loadHotel() async {
        isLoading = true
        let hotel = await appState.services.hotels.applyPointsBoost(hotelId: MockData.hotels[0].id)
        selectedHotel = hotel
        isLoading = false
    }

    private func approveHotel() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showApproveAnimation = true
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            router.navigate(to: .confirmation(tripId: tripId))
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
