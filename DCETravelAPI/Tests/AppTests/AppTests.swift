import XCTVapor
@testable import App

final class AppTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = try await Application.make(.testing)
        try configure(app)
        defer { Task { try await app.asyncShutdown() } }

        try await app.test(.GET, "api/v1/health") { res async in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
