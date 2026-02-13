import SwiftUI

struct ProfileSheetView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Avatar + user info
                VStack(spacing: 12) {
                    // Avatar circle
                    ZStack {
                        Circle()
                            .fill(DCEColors.navy)
                            .frame(width: 72, height: 72)
                        Text(initials)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                    }

                    Text(appState.currentUser.fullName)
                        .font(DCEFonts.headlineLarge())
                        .foregroundColor(DCEColors.primaryText)

                    // Tier badge
                    HStack(spacing: 6) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 13))
                            .foregroundColor(DCEColors.copper)
                        Text(appState.currentUser.membershipTier.rawValue)
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.copper)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(DCEColors.copper.opacity(0.1))
                    .clipShape(Capsule())

                    // Points
                    Text("\(formattedPoints) pts \u{00B7} ~\(formattedValue)")
                        .font(DCEFonts.bodyMedium())
                        .foregroundColor(DCEColors.secondaryText)
                }
                .padding(.top, 8)

                Divider()
                    .padding(.horizontal, 20)

                // Menu rows
                VStack(spacing: 0) {
                    menuRow(icon: "airplane.circle.fill", title: "My Trips", color: DCEColors.navy) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.navigate(to: .tripSuggestions)
                        }
                    }

                    menuRow(icon: "list.clipboard.fill", title: "My Bookings", color: DCEColors.navy) {
                        dismiss()
                        if let trip = appState.activeTrips.first {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                router.navigate(to: .bookingList(tripId: trip.id))
                            }
                        }
                    }

                    menuRow(icon: "star.circle.fill", title: "Points & Rewards", color: DCEColors.pointsBoostAccent) {
                        dismiss()
                        if let trip = appState.activeTrips.first {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                router.navigate(to: .searchResults(tripId: trip.id, category: .points))
                            }
                        }
                    }

                    menuRow(icon: "gearshape.fill", title: "Preferences", color: DCEColors.secondaryText) { }
                        .opacity(0.5)

                    menuRow(icon: "questionmark.circle.fill", title: "Help", color: DCEColors.secondaryText) { }
                        .opacity(0.5)
                }

                Spacer()
            }
            .background(DCEColors.warmBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
    }

    // MARK: - Helpers

    private var initials: String {
        let first = appState.currentUser.firstName.prefix(1)
        let last = appState.currentUser.lastName.prefix(1)
        return "\(first)\(last)"
    }

    private var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: appState.currentUser.pointsBalance)) ?? "\(appState.currentUser.pointsBalance)"
    }

    private var formattedValue: String {
        let value = Double(appState.currentUser.pointsBalance) / 100.0 * 1.5
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }

    private func menuRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 32)

                Text(title)
                    .font(DCEFonts.bodyLarge())
                    .foregroundColor(DCEColors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DCEColors.tertiaryText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
