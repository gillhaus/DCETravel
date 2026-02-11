import Foundation

class APIPointsService: PointsServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func getBalance() async -> Int {
        struct BalanceResponse: Decodable { let balance: Int }
        let response: BalanceResponse? = try? await client.get("/api/v1/points/balance")
        return response?.balance ?? 0
    }

    func calculateValue(points: Int) async -> Double {
        struct CalcBody: Encodable { let points: Int }
        struct CalcResponse: Decodable { let dollarValue: Double }
        let response: CalcResponse? = try? await client.post("/api/v1/points/calculate-value",
                                                              body: CalcBody(points: points))
        return response?.dollarValue ?? 0
    }

    func applyBoost(points: Int) async -> Int {
        struct BoostBody: Encodable { let points: Int }
        struct BoostResponse: Decodable { let boostedPoints: Int }
        let response: BoostResponse? = try? await client.post("/api/v1/points/apply-boost",
                                                               body: BoostBody(points: points))
        return response?.boostedPoints ?? points
    }
}
