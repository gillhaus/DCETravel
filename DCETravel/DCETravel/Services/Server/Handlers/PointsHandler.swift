import Foundation

struct PointsHandler {
    let dataStore: DataStore

    func balance(_ request: HTTPRequest) -> HTTPResponse {
        struct BalanceResponse: Codable {
            let balance: Int
            let tier: User.MembershipTier
            let dollarValue: Double
        }
        let user = dataStore.user
        return .json(BalanceResponse(
            balance: user.pointsBalance,
            tier: user.membershipTier,
            dollarValue: Double(user.pointsBalance) / 100.0
        ))
    }

    func calculateValue(_ request: HTTPRequest) -> HTTPResponse {
        struct CalcRequest: Codable { var points: Int? }
        struct CalcResponse: Codable {
            let points: Int
            let dollarValue: Double
            let centsPerPoint: Double
        }

        let body = request.jsonBody(CalcRequest.self)
        let points = body?.points ?? dataStore.user.pointsBalance
        let centsPerPoint = 1.0 // 1 cent per point base value
        let dollarValue = Double(points) * centsPerPoint / 100.0

        return .json(CalcResponse(points: points, dollarValue: dollarValue, centsPerPoint: centsPerPoint))
    }

    func applyBoost(_ request: HTTPRequest) -> HTTPResponse {
        struct BoostRequest: Codable { var points: Int? }
        struct BoostResponse: Codable {
            let originalPoints: Int
            let boostedPoints: Int
            let bonusPoints: Int
            let boostPercentage: Int
        }

        let body = request.jsonBody(BoostRequest.self)
        let points = body?.points ?? 100_000
        let boosted = Int(Double(points) * 1.33)
        let bonus = boosted - points

        return .json(BoostResponse(
            originalPoints: points,
            boostedPoints: boosted,
            bonusPoints: bonus,
            boostPercentage: 33
        ))
    }
}
