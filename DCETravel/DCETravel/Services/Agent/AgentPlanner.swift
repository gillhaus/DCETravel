import Foundation

struct AgentPlan {
    let steps: [PlanStep]
    let description: String

    struct PlanStep {
        let tool: AgentTool
        let parameters: [String: String]
        let description: String
        let requiresConfirmation: Bool
    }
}

class AgentPlanner {
    func createPlan(for intent: ParsedIntent, context: AgentContext) -> AgentPlan {
        switch intent.intent {
        case .planTrip:
            return planTripPlan(entities: intent.entities)
        case .searchFlights:
            return searchFlightsPlan(entities: intent.entities)
        case .bookFlight:
            return bookFlightPlan(entities: intent.entities, context: context)
        case .searchHotels:
            return searchHotelsPlan(entities: intent.entities)
        case .bookHotel:
            return bookHotelPlan(entities: intent.entities, context: context)
        case .searchRestaurants:
            return searchRestaurantsPlan(entities: intent.entities)
        case .bookRestaurant:
            return bookRestaurantPlan(entities: intent.entities, context: context)
        case .searchCars:
            return searchCarsPlan(entities: intent.entities)
        case .bookCar:
            return bookCarPlan(entities: intent.entities, context: context)
        case .checkBookings:
            return singleStepPlan(tool: .getBookings, description: "Checking your bookings")
        case .checkPoints:
            return singleStepPlan(tool: .getPointsBalance, description: "Checking your points balance")
        case .maximizePoints:
            return maximizePointsPlan(entities: intent.entities)
        case .getTripSuggestions, .searchDestination:
            return searchDestinationsPlan(entities: intent.entities)
        case .getFlightStatus:
            return flightStatusPlan(entities: intent.entities, context: context)
        case .checkBenefits:
            return benefitsPlan()
        default:
            return AgentPlan(steps: [], description: "")
        }
    }

    // MARK: - Plan Builders

    private func planTripPlan(entities: [String: String]) -> AgentPlan {
        var steps: [AgentPlan.PlanStep] = []
        let location = entities["location"] ?? ""

        if !location.isEmpty {
            steps.append(AgentPlan.PlanStep(
                tool: .searchDestinations, parameters: ["query": location],
                description: "Finding \(location)", requiresConfirmation: false))
        }

        steps.append(AgentPlan.PlanStep(
            tool: .searchFlights, parameters: entities,
            description: "Searching for flights", requiresConfirmation: false))

        steps.append(AgentPlan.PlanStep(
            tool: .searchHotels, parameters: entities,
            description: "Finding hotels", requiresConfirmation: false))

        steps.append(AgentPlan.PlanStep(
            tool: .searchRestaurants, parameters: entities,
            description: "Finding restaurants", requiresConfirmation: false))

        steps.append(AgentPlan.PlanStep(
            tool: .searchCars, parameters: entities,
            description: "Finding car rentals", requiresConfirmation: false))

        return AgentPlan(steps: steps, description: "Planning your trip to \(location.isEmpty ? "your destination" : location)")
    }

    private func searchFlightsPlan(entities: [String: String]) -> AgentPlan {
        return singleStepPlan(
            tool: .searchFlights, parameters: entities,
            description: "Searching for flights")
    }

    private func bookFlightPlan(entities: [String: String], context: AgentContext) -> AgentPlan {
        if let flights = context.lastSearchResults?.flights, !flights.isEmpty {
            return AgentPlan(steps: [
                AgentPlan.PlanStep(tool: .bookFlight, parameters: entities,
                                  description: "Booking your flight", requiresConfirmation: true)
            ], description: "Booking flight")
        }
        // Need to search first
        var steps = [AgentPlan.PlanStep(
            tool: .searchFlights, parameters: entities,
            description: "Finding available flights", requiresConfirmation: false)]
        steps.append(AgentPlan.PlanStep(
            tool: .bookFlight, parameters: entities,
            description: "Booking selected flight", requiresConfirmation: true))
        return AgentPlan(steps: steps, description: "Finding and booking a flight")
    }

    private func searchHotelsPlan(entities: [String: String]) -> AgentPlan {
        return singleStepPlan(
            tool: .searchHotels, parameters: entities,
            description: "Searching for hotels")
    }

    private func bookHotelPlan(entities: [String: String], context: AgentContext) -> AgentPlan {
        if let hotels = context.lastSearchResults?.hotels, !hotels.isEmpty {
            return AgentPlan(steps: [
                AgentPlan.PlanStep(tool: .bookHotel, parameters: entities,
                                  description: "Booking your hotel", requiresConfirmation: true)
            ], description: "Booking hotel")
        }
        var steps = [AgentPlan.PlanStep(
            tool: .searchHotels, parameters: entities,
            description: "Finding available hotels", requiresConfirmation: false)]
        steps.append(AgentPlan.PlanStep(
            tool: .bookHotel, parameters: entities,
            description: "Booking selected hotel", requiresConfirmation: true))
        return AgentPlan(steps: steps, description: "Finding and booking a hotel")
    }

    private func searchRestaurantsPlan(entities: [String: String]) -> AgentPlan {
        return singleStepPlan(
            tool: .searchRestaurants, parameters: entities,
            description: "Searching for restaurants")
    }

    private func bookRestaurantPlan(entities: [String: String], context: AgentContext) -> AgentPlan {
        if let restaurants = context.lastSearchResults?.restaurants, !restaurants.isEmpty {
            return AgentPlan(steps: [
                AgentPlan.PlanStep(tool: .bookRestaurant, parameters: entities,
                                  description: "Making your reservation", requiresConfirmation: true)
            ], description: "Reserving table")
        }
        var steps = [AgentPlan.PlanStep(
            tool: .searchRestaurants, parameters: entities,
            description: "Finding restaurants", requiresConfirmation: false)]
        steps.append(AgentPlan.PlanStep(
            tool: .bookRestaurant, parameters: entities,
            description: "Making reservation", requiresConfirmation: true))
        return AgentPlan(steps: steps, description: "Finding and reserving a restaurant")
    }

    private func searchCarsPlan(entities: [String: String]) -> AgentPlan {
        return singleStepPlan(
            tool: .searchCars, parameters: entities,
            description: "Searching for car rentals")
    }

    private func bookCarPlan(entities: [String: String], context: AgentContext) -> AgentPlan {
        if let cars = context.lastSearchResults?.carRentals, !cars.isEmpty {
            return AgentPlan(steps: [
                AgentPlan.PlanStep(tool: .bookCar, parameters: entities,
                                  description: "Booking your car rental", requiresConfirmation: true)
            ], description: "Booking car rental")
        }
        var steps = [AgentPlan.PlanStep(
            tool: .searchCars, parameters: entities,
            description: "Finding available cars", requiresConfirmation: false)]
        steps.append(AgentPlan.PlanStep(
            tool: .bookCar, parameters: entities,
            description: "Booking selected car", requiresConfirmation: true))
        return AgentPlan(steps: steps, description: "Finding and booking a car rental")
    }

    private func maximizePointsPlan(entities: [String: String]) -> AgentPlan {
        return AgentPlan(steps: [
            AgentPlan.PlanStep(tool: .getPointsBalance, parameters: [:],
                              description: "Checking your balance", requiresConfirmation: false),
            AgentPlan.PlanStep(tool: .calculatePointsValue, parameters: entities,
                              description: "Calculating value", requiresConfirmation: false),
            AgentPlan.PlanStep(tool: .applyPointsBoost, parameters: entities,
                              description: "Finding boost opportunities", requiresConfirmation: false)
        ], description: "Analyzing how to maximize your points")
    }

    private func searchDestinationsPlan(entities: [String: String]) -> AgentPlan {
        return singleStepPlan(
            tool: .searchDestinations, parameters: entities.isEmpty ? ["query": ""] : entities,
            description: "Finding destinations for you")
    }

    private func flightStatusPlan(entities: [String: String], context: AgentContext) -> AgentPlan {
        if let flightId = entities["flightId"] {
            return singleStepPlan(
                tool: .getFlightStatus, parameters: ["flightId": flightId],
                description: "Checking flight status")
        }
        // Check bookings for flights
        return AgentPlan(steps: [
            AgentPlan.PlanStep(tool: .getBookings, parameters: [:],
                              description: "Finding your flight bookings", requiresConfirmation: false)
        ], description: "Looking up your flight status")
    }

    private func benefitsPlan() -> AgentPlan {
        return singleStepPlan(tool: .getPointsBalance, description: "Checking your benefits and status")
    }

    private func singleStepPlan(tool: AgentTool, parameters: [String: String] = [:], description: String) -> AgentPlan {
        return AgentPlan(steps: [
            AgentPlan.PlanStep(tool: tool, parameters: parameters,
                              description: description, requiresConfirmation: false)
        ], description: description)
    }
}
