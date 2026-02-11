import Foundation
import Network

class LocalServer {
    private var listener: NWListener?
    private let router: Router
    private let queue = DispatchQueue(label: "com.dcetravel.localserver", qos: .userInitiated)
    private(set) var port: UInt16 = 0

    init(router: Router) {
        self.router = router
    }

    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        listener = try NWListener(using: parameters, on: .any)

        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                if let port = self?.listener?.port?.rawValue {
                    self?.port = port
                    print("[LocalServer] Listening on localhost:\(port)")
                }
            case .failed(let error):
                print("[LocalServer] Failed: \(error)")
                self?.listener?.cancel()
            case .cancelled:
                print("[LocalServer] Cancelled")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: queue)
    }

    func stop() {
        listener?.cancel()
        listener = nil
        print("[LocalServer] Stopped")
    }

    var baseURL: String {
        "http://localhost:\(port)"
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self, let data = data, !data.isEmpty else {
                connection.cancel()
                return
            }

            let request = self.parseHTTPRequest(data)
            let response = self.router.route(request)
            let responseData = response.httpData()

            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    private func parseHTTPRequest(_ data: Data) -> HTTPRequest {
        guard let raw = String(data: data, encoding: .utf8) else {
            return HTTPRequest(method: "GET", path: "/", queryParameters: [:], headers: [:], body: nil)
        }

        let lines = raw.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            return HTTPRequest(method: "GET", path: "/", queryParameters: [:], headers: [:], body: nil)
        }

        let parts = requestLine.split(separator: " ", maxSplits: 2)
        let method = parts.count > 0 ? String(parts[0]) : "GET"
        let fullPath = parts.count > 1 ? String(parts[1]) : "/"

        // Split path and query
        let pathAndQuery = fullPath.split(separator: "?", maxSplits: 1)
        let path = String(pathAndQuery[0])
        var queryParams: [String: String] = [:]

        if pathAndQuery.count > 1 {
            let queryString = String(pathAndQuery[1])
            for pair in queryString.split(separator: "&") {
                let kv = pair.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                    queryParams[key] = value
                }
            }
        }

        // Parse headers
        var headers: [String: String] = [:]
        var bodyStart = -1
        for i in 1..<lines.count {
            if lines[i].isEmpty {
                bodyStart = i + 1
                break
            }
            let headerParts = lines[i].split(separator: ":", maxSplits: 1)
            if headerParts.count == 2 {
                headers[String(headerParts[0]).trimmingCharacters(in: .whitespaces)] =
                    String(headerParts[1]).trimmingCharacters(in: .whitespaces)
            }
        }

        // Parse body
        var body: Data? = nil
        if bodyStart > 0 && bodyStart < lines.count {
            let bodyString = lines[bodyStart...].joined(separator: "\r\n")
            if !bodyString.isEmpty {
                body = bodyString.data(using: .utf8)
            }
        }

        return HTTPRequest(method: method, path: path, queryParameters: queryParams, headers: headers, body: body)
    }
}
