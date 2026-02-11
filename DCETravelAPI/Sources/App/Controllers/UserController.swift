import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let user = routes.grouped("user")
        user.get("profile", use: profile)
        user.get("preferences", use: preferences)
    }

    func profile(req: Request) throws -> User {
        return DataStore.shared.user
    }

    func preferences(req: Request) throws -> TravelPreferences {
        return DataStore.shared.user.preferences
    }
}
