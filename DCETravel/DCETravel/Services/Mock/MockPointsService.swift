import Foundation

class MockPointsService: PointsServiceProtocol {
    func getBalance() async -> Int {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...600_000_000))
        return 2_450_000
    }

    func calculateValue(points: Int) async -> Double {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...400_000_000))
        return Double(points) * 0.0125 // 1.25 cents per point
    }

    func applyBoost(points: Int) async -> Int {
        try? await Task.sleep(nanoseconds: UInt64.random(in: 300_000_000...800_000_000))
        return Int(Double(points) * 0.667) // 33% discount with boost
    }
}
