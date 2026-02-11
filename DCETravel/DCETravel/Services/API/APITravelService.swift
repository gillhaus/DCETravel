import Foundation

class APITravelService: TravelServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func searchDestinations(query: String) async -> [Destination] {
        let items = [URLQueryItem(name: "query", value: query)]
        return (try? await client.get("/api/v1/destinations/search", queryItems: items)) ?? []
    }

    func getInspiration() async -> [Destination] {
        return (try? await client.get("/api/v1/destinations/inspiration")) ?? []
    }

    func getTripSuggestions() async -> [Trip] {
        return (try? await client.get("/api/v1/trips")) ?? []
    }
}
