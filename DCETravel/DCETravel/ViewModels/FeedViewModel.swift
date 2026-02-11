import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []

    func loadFeed(appState: AppState) async {
        var items: [FeedItem] = []

        // 1. Trip countdowns from activeTrips
        let now = Date()
        let calendar = Calendar.current

        for trip in appState.activeTrips {
            let daysUntil = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: trip.startDate)).day ?? 0
            let daysAfterEnd = calendar.dateComponents([.day], from: calendar.startOfDay(for: trip.endDate), to: calendar.startOfDay(for: now)).day ?? 0

            let subtitle: String
            let icon: String

            if daysUntil > 0 {
                subtitle = "\(trip.destination) is \(daysUntil) day\(daysUntil == 1 ? "" : "s") away \u{2022} \(trip.dateRangeText)"
                icon = "calendar.badge.clock"
            } else if daysAfterEnd <= 0 && daysUntil <= 0 {
                subtitle = "\(trip.destination) trip is in progress \u{2022} \(trip.travelers.count) travelers"
                icon = "airplane.departure"
            } else if daysAfterEnd <= 7 {
                subtitle = "Just returned from \(trip.destination) \u{2022} How was your trip?"
                icon = "airplane.arrival"
            } else {
                continue
            }

            items.append(FeedItem(
                id: UUID(),
                type: .tripUpdate,
                timestamp: now.addingTimeInterval(Double(-items.count) * 60),
                title: trip.name,
                subtitle: subtitle,
                icon: icon,
                action: .openTrip(tripId: trip.id)
            ))
        }

        // 2. Recent confirmed bookings as booking alerts
        let confirmedBookings = appState.bookings.filter { $0.status == .confirmed }
        for booking in confirmedBookings {
            let typeIcon: String
            switch booking.type {
            case .flight: typeIcon = "airplane"
            case .hotel: typeIcon = "building.2"
            case .restaurant: typeIcon = "fork.knife"
            case .carRental: typeIcon = "car.fill"
            case .lounge: typeIcon = "cup.and.saucer.fill"
            case .activity: typeIcon = "ticket"
            }

            items.append(FeedItem(
                id: UUID(),
                type: .bookingAlert,
                timestamp: now.addingTimeInterval(Double(-items.count) * 120),
                title: "\(booking.type.rawValue) Confirmed",
                subtitle: "\(booking.details) \u{2022} \(booking.confirmationNumber)",
                icon: typeIcon,
                action: .openBooking(tripId: booking.tripId)
            ))
        }

        // 3. AI suggestion cards based on trip destinations
        let aiSuggestions = generateAISuggestions(for: appState.activeTrips)
        for suggestion in aiSuggestions {
            items.append(FeedItem(
                id: UUID(),
                type: .aiSuggestion,
                timestamp: now.addingTimeInterval(Double(-items.count) * 180),
                title: suggestion.title,
                subtitle: suggestion.subtitle,
                icon: "sparkles",
                action: suggestion.action
            ))
        }

        // 4. Points balance milestone
        let user = appState.currentUser
        let formattedPoints = formatPoints(user.pointsBalance)
        items.append(FeedItem(
            id: UUID(),
            type: .pointsUpdate,
            timestamp: now.addingTimeInterval(Double(-items.count) * 240),
            title: "\(formattedPoints) Points Available",
            subtitle: "\(user.membershipTier.rawValue) member \u{2022} Earn 3x on travel and dining",
            icon: "star.circle.fill",
            action: appState.activeTrips.first.map { .openSearch(tripId: $0.id, category: .points) }
        ))

        // 5. Weather preview for upcoming destinations (simulated)
        let weatherPreviews = generateWeatherPreviews(for: appState.activeTrips)
        for preview in weatherPreviews {
            items.append(FeedItem(
                id: UUID(),
                type: .weatherAlert,
                timestamp: now.addingTimeInterval(Double(-items.count) * 300),
                title: preview.title,
                subtitle: preview.subtitle,
                icon: preview.icon ?? "cloud.sun.fill",
                action: preview.action
            ))
        }

        // 6. Price drop alerts (simulated)
        let priceAlerts = generatePriceAlerts(for: appState.activeTrips)
        for alert in priceAlerts {
            items.append(FeedItem(
                id: UUID(),
                type: .priceAlert,
                timestamp: now.addingTimeInterval(Double(-items.count) * 360),
                title: alert.title,
                subtitle: alert.subtitle,
                icon: "tag.fill",
                action: alert.action
            ))
        }

        // Sort by timestamp (most recent first)
        feedItems = items.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Feed Generation Helpers

    private struct SuggestionData {
        let title: String
        let subtitle: String
        let icon: String?
        let action: FeedItem.FeedAction?

        init(title: String, subtitle: String, icon: String? = nil, action: FeedItem.FeedAction?) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
            self.action = action
        }
    }

    private func generateAISuggestions(for trips: [Trip]) -> [SuggestionData] {
        var suggestions: [SuggestionData] = []

        for trip in trips {
            let destination = trip.destination.lowercased()

            switch destination {
            case "rome":
                suggestions.append(SuggestionData(
                    title: "Restaurant Picks Near Your Hotel",
                    subtitle: "I found 3 highly-rated trattorias within walking distance of your stay in Rome. Want me to book one?",
                    action: .openChat(tripId: trip.id, message: "Recommend restaurants near my hotel in Rome")
                ))
            case "tokyo":
                suggestions.append(SuggestionData(
                    title: "Skip-the-Line Passes Available",
                    subtitle: "TeamLab Borderless and Meiji Shrine have skip-the-line passes. Shall I add them to your itinerary?",
                    action: .openChat(tripId: trip.id, message: "Tell me about skip-the-line passes in Tokyo")
                ))
            case "paris":
                suggestions.append(SuggestionData(
                    title: "Secret Courtyard Cafes",
                    subtitle: "I discovered hidden gem cafes in Le Marais that match your interest in fine dining. Want details?",
                    action: .openChat(tripId: trip.id, message: "Show me hidden cafes in Le Marais, Paris")
                ))
            case "bahamas":
                suggestions.append(SuggestionData(
                    title: "Shore Excursion Deals",
                    subtitle: "Popular snorkeling and island tours are booking up fast. I can reserve your spots now.",
                    action: .openChat(tripId: trip.id, message: "Find shore excursions for the Bahamas cruise")
                ))
            default:
                suggestions.append(SuggestionData(
                    title: "Explore \(trip.destination)",
                    subtitle: "I can help you find the best restaurants, attractions, and experiences in \(trip.destination).",
                    action: .openChat(tripId: trip.id, message: "What are the best things to do in \(trip.destination)?")
                ))
            }
        }

        return suggestions
    }

    private func generateWeatherPreviews(for trips: [Trip]) -> [SuggestionData] {
        var previews: [SuggestionData] = []

        for trip in trips {
            let daysUntil = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: Date()),
                to: Calendar.current.startOfDay(for: trip.startDate)
            ).day ?? 0

            guard daysUntil > 0 && daysUntil <= 14 else { continue }

            let destination = trip.destination.lowercased()
            let weatherInfo: (temp: String, condition: String, icon: String)

            switch destination {
            case "rome":
                weatherInfo = ("75°F", "Sunny with light clouds", "sun.max.fill")
            case "tokyo":
                weatherInfo = ("68°F", "Partly cloudy, chance of rain", "cloud.sun.fill")
            case "paris":
                weatherInfo = ("62°F", "Overcast with mild temperatures", "cloud.fill")
            case "bahamas":
                weatherInfo = ("84°F", "Clear skies and warm", "sun.max.fill")
            default:
                weatherInfo = ("72°F", "Pleasant weather expected", "cloud.sun.fill")
            }

            previews.append(SuggestionData(
                title: "\(trip.destination) Weather Preview",
                subtitle: "\(weatherInfo.temp) \u{2022} \(weatherInfo.condition) \u{2022} Pack accordingly!",
                icon: weatherInfo.icon,
                action: .openTrip(tripId: trip.id)
            ))
        }

        return previews
    }

    private func generatePriceAlerts(for trips: [Trip]) -> [SuggestionData] {
        var alerts: [SuggestionData] = []

        for trip in trips {
            let destination = trip.destination.lowercased()

            switch destination {
            case "rome":
                alerts.append(SuggestionData(
                    title: "Hotel Prices Dropped in Rome",
                    subtitle: "Luxury hotel rates dropped 12% for your dates. Save up to $680 on a 5-night stay.",
                    action: .openSearch(tripId: trip.id, category: .hotels)
                ))
            case "tokyo":
                alerts.append(SuggestionData(
                    title: "Flight Deal to Tokyo",
                    subtitle: "Business class fares dropped 15% on your preferred airlines. Prices start at $2,150.",
                    action: .openSearch(tripId: trip.id, category: .flights)
                ))
            case "bahamas":
                alerts.append(SuggestionData(
                    title: "Cruise Excursion Sale",
                    subtitle: "Early booking discount of 20% on popular shore excursions ending soon.",
                    action: .openChat(tripId: trip.id, message: "Show me discounted excursions for Bahamas")
                ))
            default:
                alerts.append(SuggestionData(
                    title: "Price Alert for \(trip.destination)",
                    subtitle: "Travel prices for \(trip.destination) have decreased. Check for savings on flights and hotels.",
                    action: .openSearch(tripId: trip.id, category: .flights)
                ))
            }
        }

        return alerts
    }

    private func formatPoints(_ points: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: points)) ?? "\(points)"
    }
}
