import Foundation

protocol TravelServiceProtocol {
    func searchDestinations(query: String) async -> [Destination]
    func getInspiration() async -> [Destination]
    func getTripSuggestions() async -> [Trip]
}
