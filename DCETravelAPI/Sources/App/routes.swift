import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api", "v1")

    // Health check
    api.get("health") { req -> [String: String] in
        return ["status": "ok"]
    }

    // Register controllers
    try api.register(collection: DestinationController())
    try api.register(collection: FlightController())
    try api.register(collection: HotelController())
    try api.register(collection: RestaurantController())
    try api.register(collection: CarRentalController())
    try api.register(collection: BookingController())
    try api.register(collection: TripController())
    try api.register(collection: PointsController())
    try api.register(collection: UserController())
}
