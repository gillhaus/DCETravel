import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User
    @Published var activeTrips: [Trip] = []
    @Published var completedTrips: [Trip] = []
    @Published var chatMessages: [UUID: [ChatMessage]] = [:]
    @Published var bookings: [Booking] = []
    @Published var isLoading: Bool = false
    @Published var pendingChatAction: String?
    @Published var inspirationDestinations: [Destination] = []

    var services: ServiceContainer

    init(services: ServiceContainer = .shared) {
        self.services = services
        self.currentUser = User(
            id: UUID(),
            firstName: "Victoria",
            lastName: "Chen",
            email: "victoria@example.com",
            pointsBalance: 2_450_000,
            membershipTier: .reserve,
            preferences: TravelPreferences(
                preferredAirlines: ["United", "Delta"],
                preferredHotelChains: ["Marriott", "Four Seasons"],
                dietaryRestrictions: [],
                seatPreference: "Window",
                interests: ["History", "Fine Dining", "Art", "Architecture"]
            ),
            tripHistory: []
        )
    }

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }

        // Load trips from services
        activeTrips = await services.travel.getTripSuggestions()

        // Load inspiration destinations
        inspirationDestinations = await services.travel.getInspiration()

        // Load bookings
        bookings = await services.bookings.getBookings()

        // If no trips loaded (mock mode), create the Rome trip
        if activeTrips.isEmpty || !activeTrips.contains(where: { $0.destination == "Rome" }) {
            let romeTrip = Trip(
                id: UUID(),
                name: "Girl's trip to Rome",
                destination: "Rome",
                destinationCountry: "Italy",
                imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800",
                startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!,
                endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 29))!,
                travelers: ["Victoria", "Jaclyn", "Daphne", "Harper"],
                status: .planning,
                itinerary: nil,
                bookings: []
            )
            activeTrips.insert(romeTrip, at: 0)
        }

        // Fallback for inspiration if empty
        if inspirationDestinations.isEmpty {
            inspirationDestinations = MockData.destinations
        }
    }

    func addBooking(_ booking: Booking) {
        bookings.append(booking)
        if let idx = activeTrips.firstIndex(where: { $0.id == booking.tripId }) {
            activeTrips[idx].bookings.append(booking.id)
        }
    }

    func cancelBooking(_ bookingId: UUID) async {
        let success = await services.bookings.cancelBooking(id: bookingId)
        if success {
            if let idx = bookings.firstIndex(where: { $0.id == bookingId }) {
                bookings[idx].status = .cancelled
            }
        }
    }

    func refreshBookings() async {
        bookings = await services.bookings.getBookings()
    }
}
