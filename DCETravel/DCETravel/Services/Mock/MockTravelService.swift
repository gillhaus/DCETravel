import Foundation

class MockTravelService: TravelServiceProtocol {
    func searchDestinations(query: String) async -> [Destination] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        return MockData.destinations.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.country.localizedCaseInsensitiveContains(query)
        }
    }

    func getInspiration() async -> [Destination] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        return MockData.destinations
    }

    func getTripSuggestions() async -> [Trip] {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 500_000_000...1_000_000_000))
        return MockData.trips
    }
}
