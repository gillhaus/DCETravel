import Vapor

struct PointsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let points = routes.grouped("points")
        points.get("balance", use: balance)
        points.post("calculate-value", use: calculateValue)
        points.post("apply-boost", use: applyBoost)
    }

    struct BalanceResponse: Content {
        let balance: Int
        let tier: User.MembershipTier
        let dollarValue: Double
    }

    func balance(req: Request) throws -> BalanceResponse {
        let user = DataStore.shared.user
        return BalanceResponse(
            balance: user.pointsBalance,
            tier: user.membershipTier,
            dollarValue: Double(user.pointsBalance) / 100.0
        )
    }

    struct CalcRequest: Content {
        var points: Int?
    }

    struct CalcResponse: Content {
        let points: Int
        let dollarValue: Double
        let centsPerPoint: Double
    }

    func calculateValue(req: Request) throws -> CalcResponse {
        let body = try? req.content.decode(CalcRequest.self)
        let points = body?.points ?? DataStore.shared.user.pointsBalance
        let centsPerPoint = 1.0 // 1 cent per point base value
        let dollarValue = Double(points) * centsPerPoint / 100.0

        return CalcResponse(points: points, dollarValue: dollarValue, centsPerPoint: centsPerPoint)
    }

    struct BoostRequest: Content {
        var points: Int?
    }

    struct BoostResponse: Content {
        let originalPoints: Int
        let boostedPoints: Int
        let bonusPoints: Int
        let boostPercentage: Int
    }

    func applyBoost(req: Request) throws -> BoostResponse {
        let body = try? req.content.decode(BoostRequest.self)
        let points = body?.points ?? 100_000
        let boosted = Int(Double(points) * 1.33)
        let bonus = boosted - points

        return BoostResponse(
            originalPoints: points,
            boostedPoints: boosted,
            bonusPoints: bonus,
            boostPercentage: 33
        )
    }
}
