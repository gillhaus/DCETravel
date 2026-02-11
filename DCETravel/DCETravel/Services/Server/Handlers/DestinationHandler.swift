import Foundation

struct DestinationHandler {
    let dataStore: DataStore

    func search(_ request: HTTPRequest) -> HTTPResponse {
        let query = (request.queryParameters["query"] ?? "").lowercased()
        if query.isEmpty {
            return .json(dataStore.destinations)
        }
        let results = dataStore.destinations.filter {
            $0.name.lowercased().contains(query) ||
            $0.country.lowercased().contains(query) ||
            $0.tags.contains { $0.lowercased().contains(query) }
        }
        return .json(results)
    }

    func inspiration(_ request: HTTPRequest) -> HTTPResponse {
        let results = dataStore.destinations.filter {
            $0.category == .inspiration || $0.category == .trending || $0.category == .recommended
        }
        return .json(results)
    }

    func getById(_ request: HTTPRequest) -> HTTPResponse {
        let components = request.pathComponents
        guard let idString = components.last, let id = UUID(uuidString: idString) else {
            return .badRequest("Invalid destination ID")
        }
        guard let destination = dataStore.destinations.first(where: { $0.id == id }) else {
            return .notFound("Destination not found")
        }
        return .json(destination)
    }
}
