import Vapor

struct DestinationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let destinations = routes.grouped("destinations")
        destinations.get("search", use: search)
        destinations.get("inspiration", use: inspiration)
        destinations.get(":id", use: getById)
    }

    func search(req: Request) throws -> [Destination] {
        let query: String = (try? req.query.get(String.self, at: "query")) ?? ""
        let lowered = query.lowercased()

        if lowered.isEmpty {
            return DataStore.shared.destinations
        }

        let results = DataStore.shared.destinations.filter {
            $0.name.lowercased().contains(lowered) ||
            $0.country.lowercased().contains(lowered) ||
            $0.tags.contains { $0.lowercased().contains(lowered) }
        }
        return results
    }

    func inspiration(req: Request) throws -> [Destination] {
        let results = DataStore.shared.destinations.filter {
            $0.category == .inspiration || $0.category == .trending || $0.category == .recommended
        }
        return results
    }

    func getById(req: Request) throws -> Destination {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid destination ID")
        }
        guard let destination = DataStore.shared.destinations.first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Destination not found")
        }
        return destination
    }
}
