import Foundation

protocol PointsServiceProtocol {
    func getBalance() async -> Int
    func calculateValue(points: Int) async -> Double
    func applyBoost(points: Int) async -> Int
}
