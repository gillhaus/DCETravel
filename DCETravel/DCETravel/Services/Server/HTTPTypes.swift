import Foundation

struct HTTPRequest {
    let method: String
    let path: String
    let queryParameters: [String: String]
    let headers: [String: String]
    let body: Data?

    var pathComponents: [String] {
        path.split(separator: "/").map(String.init)
    }

    func pathParameter(at index: Int) -> String? {
        let components = pathComponents
        guard index < components.count else { return nil }
        return components[index]
    }

    func jsonBody<T: Decodable>(_ type: T.Type) -> T? {
        guard let body = body else { return nil }
        return try? JSONDecoder.apiDecoder.decode(type, from: body)
    }
}

struct HTTPResponse {
    var statusCode: Int
    var headers: [String: String]
    var body: Data?

    static func ok(_ body: Data? = nil) -> HTTPResponse {
        HTTPResponse(statusCode: 200, headers: ["Content-Type": "application/json"], body: body)
    }

    static func created(_ body: Data? = nil) -> HTTPResponse {
        HTTPResponse(statusCode: 201, headers: ["Content-Type": "application/json"], body: body)
    }

    static func notFound(_ message: String = "Not found") -> HTTPResponse {
        let body = try? JSONEncoder.apiEncoder.encode(["error": message])
        return HTTPResponse(statusCode: 404, headers: ["Content-Type": "application/json"], body: body)
    }

    static func badRequest(_ message: String = "Bad request") -> HTTPResponse {
        let body = try? JSONEncoder.apiEncoder.encode(["error": message])
        return HTTPResponse(statusCode: 400, headers: ["Content-Type": "application/json"], body: body)
    }

    static func json<T: Encodable>(_ value: T, status: Int = 200) -> HTTPResponse {
        let body = try? JSONEncoder.apiEncoder.encode(value)
        return HTTPResponse(statusCode: status, headers: ["Content-Type": "application/json"], body: body)
    }

    func httpData() -> Data {
        var response = "HTTP/1.1 \(statusCode) \(statusText)\r\n"
        var allHeaders = headers
        if let body = body {
            allHeaders["Content-Length"] = "\(body.count)"
        } else {
            allHeaders["Content-Length"] = "0"
        }
        allHeaders["Connection"] = "close"
        for (key, value) in allHeaders {
            response += "\(key): \(value)\r\n"
        }
        response += "\r\n"

        var data = Data(response.utf8)
        if let body = body {
            data.append(body)
        }
        return data
    }

    private var statusText: String {
        switch statusCode {
        case 200: return "OK"
        case 201: return "Created"
        case 204: return "No Content"
        case 400: return "Bad Request"
        case 404: return "Not Found"
        case 405: return "Method Not Allowed"
        case 500: return "Internal Server Error"
        default: return "OK"
        }
    }
}

extension JSONEncoder {
    static let apiEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

extension JSONDecoder {
    static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
