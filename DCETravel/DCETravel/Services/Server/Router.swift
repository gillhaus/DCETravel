import Foundation

typealias RouteHandler = (HTTPRequest) -> HTTPResponse

struct RoutePattern {
    let method: String
    let pathPattern: [PathSegment]
    let handler: RouteHandler

    enum PathSegment: Equatable {
        case literal(String)
        case parameter(String)

        static func == (lhs: PathSegment, rhs: PathSegment) -> Bool {
            switch (lhs, rhs) {
            case (.literal(let a), .literal(let b)): return a == b
            case (.parameter, .parameter): return true
            default: return false
            }
        }
    }
}

class Router {
    private var routes: [RoutePattern] = []

    func addRoute(_ method: String, _ path: String, handler: @escaping RouteHandler) {
        let segments = path.split(separator: "/").map { segment -> RoutePattern.PathSegment in
            let s = String(segment)
            if s.hasPrefix(":") {
                return .parameter(String(s.dropFirst()))
            }
            return .literal(s)
        }
        routes.append(RoutePattern(method: method, pathPattern: segments, handler: handler))
    }

    func get(_ path: String, handler: @escaping RouteHandler) {
        addRoute("GET", path, handler: handler)
    }

    func post(_ path: String, handler: @escaping RouteHandler) {
        addRoute("POST", path, handler: handler)
    }

    func put(_ path: String, handler: @escaping RouteHandler) {
        addRoute("PUT", path, handler: handler)
    }

    func delete(_ path: String, handler: @escaping RouteHandler) {
        addRoute("DELETE", path, handler: handler)
    }

    func route(_ request: HTTPRequest) -> HTTPResponse {
        let requestSegments = request.path.split(separator: "/").map(String.init)

        for route in routes {
            guard route.method == request.method else { continue }
            guard route.pathPattern.count == requestSegments.count else { continue }

            var matches = true
            for (pattern, actual) in zip(route.pathPattern, requestSegments) {
                switch pattern {
                case .literal(let expected):
                    if expected != actual {
                        matches = false
                    }
                case .parameter:
                    continue // Parameters match anything
                }
                if !matches { break }
            }

            if matches {
                return route.handler(request)
            }
        }

        // Check if path matches but method doesn't
        let pathMatches = routes.contains { route in
            guard route.pathPattern.count == requestSegments.count else { return false }
            return zip(route.pathPattern, requestSegments).allSatisfy { pattern, actual in
                switch pattern {
                case .literal(let expected): return expected == actual
                case .parameter: return true
                }
            }
        }

        if pathMatches {
            return HTTPResponse(statusCode: 405, headers: ["Content-Type": "application/json"],
                              body: try? JSONEncoder.apiEncoder.encode(["error": "Method not allowed"]))
        }

        return .notFound("No route matches \(request.method) \(request.path)")
    }
}
