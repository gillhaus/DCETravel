import Foundation

enum Intent: String {
    case searchDestination
    case planTrip
    case searchFlights
    case bookFlight
    case searchHotels
    case bookHotel
    case searchRestaurants
    case bookRestaurant
    case searchCars
    case bookCar
    case checkBookings
    case manageBooking
    case checkPoints
    case maximizePoints
    case checkBenefits
    case getTripSuggestions
    case getFlightStatus
    case generalHelp
    case greeting
    case confirmation
    case rejection
    case followUp
}

struct ParsedIntent {
    let intent: Intent
    let confidence: Double
    let entities: [String: String]
}

class IntentParser {
    private let destinationNames: [String]

    init(destinationNames: [String] = []) {
        self.destinationNames = destinationNames
    }

    func parse(_ text: String, context: AgentContext? = nil) -> ParsedIntent {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var entities: [String: String] = [:]

        // Extract entities first
        extractEntities(from: lower, into: &entities)

        // Score each domain
        let scores = calculateScores(lower)

        // Check for simple patterns first
        if let simple = matchSimplePatterns(lower, context: context, entities: entities) {
            return simple
        }

        // Find best scoring intent
        let bestDomain = scores.max(by: { $0.value < $1.value })

        // Context-aware disambiguation
        if let context = context, let lastDomain = context.lastDomain {
            // "book it", "yes", "that one" → use context domain
            if isConfirmation(lower) && context.pendingAction != nil {
                return ParsedIntent(intent: .confirmation, confidence: 0.9, entities: entities)
            }
        }

        guard let domain = bestDomain, domain.value > 0 else {
            // Low confidence fallback
            if lower.count < 10 {
                return ParsedIntent(intent: .generalHelp, confidence: 0.3, entities: entities)
            }
            return ParsedIntent(intent: .followUp, confidence: 0.4, entities: entities)
        }

        let intent = mapDomainToIntent(domain.key, entities: entities, text: lower)
        let confidence = min(domain.value / 3.0, 1.0) // Normalize to 0-1

        return ParsedIntent(intent: intent, confidence: confidence, entities: entities)
    }

    // MARK: - Simple Pattern Matching

    private func matchSimplePatterns(_ text: String, context: AgentContext?, entities: [String: String]) -> ParsedIntent? {
        // Greetings
        let greetings = ["hello", "hi", "hey", "good morning", "good afternoon", "good evening", "howdy"]
        if greetings.contains(where: { text.hasPrefix($0) }) && text.count < 30 {
            return ParsedIntent(intent: .greeting, confidence: 0.95, entities: entities)
        }

        // Confirmations
        if isConfirmation(text) {
            return ParsedIntent(intent: .confirmation, confidence: 0.9, entities: entities)
        }

        // Rejections
        let rejections = ["no", "nope", "show others", "show more", "different", "other options",
                         "not that one", "never mind", "cancel that"]
        if rejections.contains(where: { text.contains($0) }) {
            return ParsedIntent(intent: .rejection, confidence: 0.85, entities: entities)
        }

        // Help
        if text == "help" || text == "what can you do" || text.hasPrefix("help me") {
            return ParsedIntent(intent: .generalHelp, confidence: 0.9, entities: entities)
        }

        return nil
    }

    private func isConfirmation(_ text: String) -> Bool {
        let confirmations = ["yes", "yeah", "yep", "sure", "ok", "okay", "book it", "do it",
                            "go ahead", "sounds good", "perfect", "that one", "let's do it",
                            "confirm", "book that", "reserve it", "i'll take it"]
        return confirmations.contains(where: { text.contains($0) })
    }

    // MARK: - Entity Extraction

    private func extractEntities(from text: String, into entities: inout [String: String]) {
        // Location extraction - match known destinations
        for name in destinationNames {
            if text.contains(name.lowercased()) {
                entities["location"] = name
                break
            }
        }

        // Date extraction
        if let dateMatch = extractDate(from: text) {
            entities["date"] = dateMatch
        }

        // Guest count
        let guestPattern = try? NSRegularExpression(pattern: "(\\d+)\\s*(?:guest|people|person|traveler|pax)", options: .caseInsensitive)
        if let match = guestPattern?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            entities["guests"] = String(text[range])
        }

        // Cuisine
        let cuisines = ["italian", "japanese", "french", "chinese", "mexican", "thai", "indian",
                       "mediterranean", "roman", "seafood", "sushi", "pizza", "fine dining"]
        for cuisine in cuisines {
            if text.contains(cuisine) {
                entities["cuisine"] = cuisine.capitalized
                break
            }
        }

        // Cabin class
        let cabinClasses = ["economy", "premium economy", "business", "first class", "first"]
        for cabin in cabinClasses {
            if text.contains(cabin) {
                entities["cabinClass"] = cabin.capitalized
                break
            }
        }

        // Airport codes (3 uppercase letters)
        let airportPattern = try? NSRegularExpression(pattern: "\\b([A-Z]{3})\\b")
        let matches = airportPattern?.matches(in: text.uppercased(), range: NSRange(text.startIndex..., in: text)) ?? []
        if matches.count >= 2 {
            if let r1 = Range(matches[0].range(at: 1), in: text.uppercased()),
               let r2 = Range(matches[1].range(at: 1), in: text.uppercased()) {
                entities["origin"] = String(text.uppercased()[r1])
                entities["destination_airport"] = String(text.uppercased()[r2])
            }
        }
    }

    private func extractDate(from text: String) -> String? {
        let datePatterns = [
            "(?:january|february|march|april|may|june|july|august|september|october|november|december)\\s+\\d{1,2}",
            "\\d{1,2}/\\d{1,2}(?:/\\d{2,4})?",
            "next\\s+(?:week|month|monday|tuesday|wednesday|thursday|friday|saturday|sunday)",
            "tomorrow",
            "this\\s+weekend"
        ]

        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range, in: text) {
                return String(text[range])
            }
        }
        return nil
    }

    // MARK: - Domain Scoring

    private func calculateScores(_ text: String) -> [String: Double] {
        var scores: [String: Double] = [:]

        let flightWords: [(String, Double)] = [
            ("flight", 3), ("fly", 2.5), ("airline", 2), ("airport", 2),
            ("departure", 1.5), ("arrival", 1.5), ("boarding", 1.5),
            ("seat", 1), ("cabin", 1), ("plane", 2), ("nonstop", 1.5),
            ("layover", 1.5), ("terminal", 1)
        ]

        let hotelWords: [(String, Double)] = [
            ("hotel", 3), ("stay", 2), ("room", 2), ("accommodation", 2.5),
            ("resort", 2.5), ("check-in", 2), ("check-out", 2), ("night", 1.5),
            ("suite", 2), ("amenit", 1.5), ("lodging", 2)
        ]

        let restaurantWords: [(String, Double)] = [
            ("restaurant", 3), ("dining", 2.5), ("dinner", 2), ("lunch", 2),
            ("breakfast", 1.5), ("eat", 2), ("food", 2), ("cuisine", 2.5),
            ("reservation", 2.5), ("table", 1.5), ("menu", 1.5),
            ("michelin", 2), ("brunch", 2)
        ]

        let carWords: [(String, Double)] = [
            ("car", 3), ("rental", 2.5), ("rent a car", 3), ("vehicle", 2),
            ("drive", 2), ("suv", 2), ("sedan", 2), ("convertible", 2),
            ("pickup", 1.5), ("dropoff", 1.5), ("hertz", 2), ("avis", 2),
            ("enterprise", 2), ("europcar", 2), ("compact", 1.5), ("luxury car", 2.5)
        ]

        let pointsWords: [(String, Double)] = [
            ("points", 3), ("miles", 2), ("rewards", 2), ("redeem", 2.5),
            ("balance", 2), ("boost", 2.5), ("value", 1.5), ("earn", 2),
            ("sapphire", 2), ("tier", 1.5), ("membership", 1.5)
        ]

        let bookingWords: [(String, Double)] = [
            ("booking", 3), ("reservation", 2), ("confirmation", 2),
            ("itinerary", 2), ("cancel", 2.5), ("modify", 2),
            ("change", 1.5), ("manage", 2), ("my bookings", 3),
            ("upcoming", 1.5)
        ]

        let tripWords: [(String, Double)] = [
            ("trip", 2.5), ("travel", 2), ("destination", 2.5), ("vacation", 2.5),
            ("plan", 2), ("suggest", 2), ("recommend", 2), ("inspiration", 2),
            ("explore", 1.5), ("visit", 1.5), ("go to", 2)
        ]

        let benefitsWords: [(String, Double)] = [
            ("benefit", 3), ("perk", 2.5), ("lounge", 2), ("upgrade", 2),
            ("priority", 2), ("access", 1.5), ("member", 2), ("reserve status", 3)
        ]

        scores["flight"] = score(text: text, keywords: flightWords)
        scores["hotel"] = score(text: text, keywords: hotelWords)
        scores["restaurant"] = score(text: text, keywords: restaurantWords)
        scores["car"] = score(text: text, keywords: carWords)
        scores["points"] = score(text: text, keywords: pointsWords)
        scores["booking"] = score(text: text, keywords: bookingWords)
        scores["trip"] = score(text: text, keywords: tripWords)
        scores["benefits"] = score(text: text, keywords: benefitsWords)

        return scores
    }

    private func score(text: String, keywords: [(String, Double)]) -> Double {
        var total: Double = 0
        for (keyword, weight) in keywords {
            if text.contains(keyword) {
                total += weight
            }
        }
        return total
    }

    // MARK: - Intent Mapping

    private func mapDomainToIntent(_ domain: String, entities: [String: String], text: String) -> Intent {
        let isBookAction = text.contains("book") || text.contains("reserve") || text.contains("get")

        switch domain {
        case "flight":
            if text.contains("status") { return .getFlightStatus }
            if isBookAction && entities["location"] != nil { return .bookFlight }
            return .searchFlights
        case "hotel":
            if isBookAction { return .bookHotel }
            return .searchHotels
        case "restaurant":
            if isBookAction || text.contains("reserve") { return .bookRestaurant }
            return .searchRestaurants
        case "car":
            if isBookAction { return .bookCar }
            return .searchCars
        case "points":
            if text.contains("maximize") || text.contains("boost") || text.contains("best value") {
                return .maximizePoints
            }
            return .checkPoints
        case "booking":
            if text.contains("cancel") || text.contains("modify") || text.contains("change") {
                return .manageBooking
            }
            return .checkBookings
        case "trip":
            if text.contains("suggest") || text.contains("recommend") || text.contains("inspiration") {
                return .getTripSuggestions
            }
            if text.contains("plan") || entities["location"] != nil { return .planTrip }
            return .searchDestination
        case "benefits":
            return .checkBenefits
        default:
            return .generalHelp
        }
    }
}
