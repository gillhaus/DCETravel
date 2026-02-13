import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var upcomingTrip: Trip?
    @Published var daysUntilTrip: Int = 0
    @Published var tripBookingsCount: Int = 0
    @Published var nextBooking: Booking?
    @Published var aiSuggestion: (title: String, subtitle: String, tripId: UUID)?
    @Published var pointsBalance: Int = 0
    @Published var pointsValue: Double = 0
    @Published var membershipTier: User.MembershipTier = .sapphire
    @Published var inspirationDestinations: [Destination] = []

    func loadData(appState: AppState) async {
        let now = Date()
        let calendar = Calendar.current

        // Find nearest future trip
        let futureTrips = appState.activeTrips
            .filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }
        upcomingTrip = futureTrips.first

        if let trip = upcomingTrip {
            daysUntilTrip = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: now),
                to: calendar.startOfDay(for: trip.startDate)
            ).day ?? 0

            // Count confirmed bookings for this trip
            let tripBookings = appState.bookings.filter {
                $0.tripId == trip.id && $0.status == .confirmed
            }
            tripBookingsCount = tripBookings.count

            // Soonest confirmed booking
            nextBooking = tripBookings
                .sorted { $0.date < $1.date }
                .first

            // AI suggestion based on destination
            aiSuggestion = generateAISuggestion(for: trip)
        }

        // Points
        let user = appState.currentUser
        pointsBalance = user.pointsBalance
        membershipTier = user.membershipTier
        pointsValue = Double(user.pointsBalance) / 100.0 * 1.5  // 1.5 cents per point

        // Inspiration
        inspirationDestinations = appState.inspirationDestinations.isEmpty
            ? MockData.destinations
            : appState.inspirationDestinations
    }

    var formattedPoints: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: pointsBalance)) ?? "\(pointsBalance)"
    }

    var formattedPointsValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: pointsValue)) ?? "$\(Int(pointsValue))"
    }

    // MARK: - AI Suggestion

    private func generateAISuggestion(for trip: Trip) -> (title: String, subtitle: String, tripId: UUID) {
        let destination = trip.destination.lowercased()

        switch destination {
        case "rome":
            return (
                "Restaurant Picks Near Your Hotel",
                "3 highly-rated trattorias within walking distance",
                trip.id
            )
        case "tokyo":
            return (
                "Skip-the-Line Passes Available",
                "TeamLab Borderless and Meiji Shrine have skip-the-line passes",
                trip.id
            )
        case "paris":
            return (
                "Secret Courtyard Cafes",
                "Hidden gem cafes in Le Marais that match your interests",
                trip.id
            )
        default:
            return (
                "Explore \(trip.destination)",
                "Discover the best restaurants, attractions, and experiences",
                trip.id
            )
        }
    }
}
