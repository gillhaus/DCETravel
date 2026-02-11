import Foundation

struct UserHandler {
    let dataStore: DataStore

    func profile(_ request: HTTPRequest) -> HTTPResponse {
        return .json(dataStore.user)
    }

    func preferences(_ request: HTTPRequest) -> HTTPResponse {
        return .json(dataStore.user.preferences)
    }
}
