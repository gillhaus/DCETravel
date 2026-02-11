import Foundation

enum MockData {
    // MARK: - Destinations
    static let destinations: [Destination] = [
        Destination(
            id: UUID(), name: "Tokyo", country: "Japan",
            imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800",
            tags: ["Culture", "Food", "Modern"],
            description: "A fascinating blend of ancient traditions and cutting-edge technology.",
            suggestedDates: "Mar 15 - Mar 25",
            category: .trending
        ),
        Destination(
            id: UUID(), name: "Los Angeles", country: "USA",
            imageURL: "https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?w=800",
            tags: ["Beach", "Entertainment", "Food"],
            description: "Sun-soaked beaches, world-class dining, and endless entertainment.",
            suggestedDates: "Apr 5 - Apr 12",
            category: .trending
        ),
        Destination(
            id: UUID(), name: "Paris", country: "France",
            imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800",
            tags: ["Romance", "Art", "Food"],
            description: "The City of Light offers unparalleled art, cuisine, and charm.",
            suggestedDates: "May 1 - May 8",
            category: .inspiration
        ),
        Destination(
            id: UUID(), name: "Cairo", country: "Egypt",
            imageURL: "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800",
            tags: ["Ancient history", "Culture", "Adventure"],
            description: "Explore millennia of history from the Pyramids to bustling bazaars.",
            suggestedDates: "Mar 23 - Apr 4",
            category: .recommended
        ),
        Destination(
            id: UUID(), name: "Bali", country: "Indonesia",
            imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800",
            tags: ["Relaxation", "Temples", "Nature"],
            description: "Tropical paradise with ancient temples, rice terraces, and stunning beaches.",
            suggestedDates: nil,
            category: .inspiration
        ),
        Destination(
            id: UUID(), name: "Barcelona", country: "Spain",
            imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800",
            tags: ["Architecture", "Beach", "Nightlife"],
            description: "Gaudí's masterpieces, Mediterranean beaches, and vibrant culture.",
            suggestedDates: "Jun 10 - Jun 17",
            category: .popular
        )
    ]

    // MARK: - Trips
    static let trips: [Trip] = [
        Trip(
            id: UUID(), name: "Bahamas Cruise", destination: "Bahamas",
            destinationCountry: "Caribbean",
            imageURL: "https://images.unsplash.com/photo-1548574505-5e239809ee19?w=800",
            startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 15))!,
            endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 22))!,
            travelers: ["Victoria", "Marcus"],
            status: .planning,
            itinerary: nil,
            bookings: []
        )
    ]

    // MARK: - Hotels
    static let hotels: [Hotel] = [
        Hotel(
            id: UUID(), name: "Portrait Roma", brand: "Lungarno Collection",
            starRating: 5, userRating: 5.0, ratingCount: 892,
            location: "Rome, Italy", locationDetail: "Central location",
            pricePerNight: 5651, totalPrice: 28255,
            pointsCost: 1_255_768, originalPointsCost: 1_883_652,
            amenities: ["Daily breakfast for 2", "Early check-in", "Late check-out", "$100 property credit", "Room upgrade", "Spa access"],
            imageURLs: [
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
                "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800"
            ],
            tier: .theEdit,
            description: "An intimate luxury hotel overlooking the Via Condotti, offering personalized service and stunning views of Rome's historic center."
        ),
        Hotel(
            id: UUID(), name: "Hotel de Russie", brand: "Rocco Forte Hotels",
            starRating: 5, userRating: 4.8, ratingCount: 1245,
            location: "Rome, Italy", locationDetail: "Near Piazza del Popolo",
            pricePerNight: 4200, totalPrice: 21000,
            pointsCost: 980_000, originalPointsCost: 1_470_000,
            amenities: ["Spa", "Garden", "Restaurant", "Bar", "Fitness center"],
            imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
            tier: .luxury,
            description: "A stunning property set between Piazza del Popolo and the Spanish Steps with beautiful secret gardens."
        ),
        Hotel(
            id: UUID(), name: "The St. Regis Rome", brand: "Marriott",
            starRating: 5, userRating: 4.7, ratingCount: 987,
            location: "Rome, Italy", locationDetail: "Near Trevi Fountain",
            pricePerNight: 3800, totalPrice: 19000,
            pointsCost: 850_000, originalPointsCost: 1_275_000,
            amenities: ["Butler service", "Spa", "Restaurant", "Rooftop bar"],
            imageURLs: ["https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800"],
            tier: .premium,
            description: "Grand dame hotel with opulent decor, impeccable butler service, and a prime location near the Trevi Fountain."
        )
    ]

    // MARK: - Flights
    static let flights: [Flight] = [
        Flight(
            id: UUID(), airline: "United Airlines", flightNumber: "UA 412",
            departureAirport: "LAX", arrivalAirport: "FCO",
            departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 17, minute: 30))!,
            arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 13, minute: 45))!,
            price: 2850, pointsCost: 85000,
            cabinClass: .business, status: .scheduled
        ),
        Flight(
            id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 178",
            departureAirport: "LAX", arrivalAirport: "FCO",
            departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 21, minute: 15))!,
            arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 17, minute: 30))!,
            price: 2450, pointsCost: 72000,
            cabinClass: .business, status: .scheduled
        )
    ]

    // MARK: - Restaurants
    static let restaurants: [Restaurant] = [
        Restaurant(
            id: UUID(), name: "Armando Al Pantheon",
            cuisine: "Traditional Roman",
            rating: 4.7, priceLevel: "$$$",
            imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
            location: "Near the Pantheon, Rome",
            reservationDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 25))!,
            reservationTime: "8:00 PM",
            guestCount: 4,
            isBooked: true,
            description: "A beloved trattoria steps from the Pantheon, serving authentic Roman cuisine since 1961."
        ),
        Restaurant(
            id: UUID(), name: "La Pergola",
            cuisine: "Fine Dining Italian",
            rating: 4.9, priceLevel: "$$$$",
            imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800",
            location: "Rome Cavalieri Hotel",
            reservationDate: nil, reservationTime: nil, guestCount: nil,
            isBooked: false,
            description: "Rome's only three-Michelin-star restaurant with panoramic city views."
        )
    ]

    // MARK: - Itinerary Themes
    static let itineraryThemes: [ItineraryTheme] = [
        ItineraryTheme(
            id: UUID(),
            title: "Take in Roman history",
            subtitle: "Explore ancient ruins, Renaissance art, and centuries of culture",
            tags: ["Historical sites", "5-star hotel", "Local food"],
            imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800"
        ),
        ItineraryTheme(
            id: UUID(),
            title: "Luxury shopping & dining",
            subtitle: "Designer boutiques, Michelin restaurants, and VIP experiences",
            tags: ["Shopping", "High-end dining", "Spa"],
            imageURL: "https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800"
        ),
        ItineraryTheme(
            id: UUID(),
            title: "Local hidden gems",
            subtitle: "Off-the-beaten-path trattorias, artisan workshops, and secret gardens",
            tags: ["Local food", "Art", "Walking tours"],
            imageURL: "https://images.unsplash.com/photo-1529260830199-42c24126f198?w=800"
        )
    ]

    // MARK: - Bookings
    static let bookings: [Booking] = [
        Booking(
            id: UUID(), type: .hotel, status: .confirmed,
            confirmationNumber: "HT847291",
            tripId: UUID(),
            details: "Portrait Roma - 5 night stay",
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!
        ),
        Booking(
            id: UUID(), type: .flight, status: .confirmed,
            confirmationNumber: "FL293847",
            tripId: UUID(),
            details: "United UA 412 - LAX to FCO",
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!
        ),
        Booking(
            id: UUID(), type: .restaurant, status: .confirmed,
            confirmationNumber: "RS182736",
            tripId: UUID(),
            details: "Armando Al Pantheon - 4 guests",
            date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 25))!
        )
    ]

    // MARK: - Update Alerts
    static let updateAlerts: [UpdateAlert] = [
        UpdateAlert(
            id: UUID(),
            title: "Los Angeles to Newark",
            subtitle: "Flight schedule change",
            type: .urgent,
            icon: "airplane",
            tripName: "NYC Weekend"
        ),
        UpdateAlert(
            id: UUID(),
            title: "Bahamas cruise",
            subtitle: "Deposit due in 3 days",
            type: .warning,
            icon: "dollarsign.circle",
            tripName: "Bahamas Cruise"
        )
    ]
}

// MARK: - Update Alert Model
struct UpdateAlert: Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var type: AlertType
    var icon: String
    var tripName: String

    enum AlertType: String, Codable {
        case urgent
        case warning
        case info
    }
}
