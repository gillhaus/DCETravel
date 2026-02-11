import Foundation

class APIClient {
    let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: String) {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder.apiDecoder
        self.encoder = JSONEncoder.apiEncoder
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        var components = URLComponents(string: baseURL + path)!
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func post<T: Decodable>(_ path: String) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        let (data, _) = try await session.data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    func delete(_ path: String) async throws -> Bool {
        var request = URLRequest(url: URL(string: baseURL + path)!)
        request.httpMethod = "DELETE"
        let (data, _) = try await session.data(for: request)
        struct DeleteResponse: Decodable { let success: Bool }
        let response = try decoder.decode(DeleteResponse.self, from: data)
        return response.success
    }
}
