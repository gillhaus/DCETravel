import Foundation

class ClaudeAPIClient {
    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL = "https://api.anthropic.com/v1/messages"

    init(apiKey: String, model: String = "claude-sonnet-4-20250514") {
        self.apiKey = apiKey
        self.model = model
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        self.session = URLSession(configuration: config)
    }

    struct MessagesRequest: Encodable {
        let model: String
        let max_tokens: Int
        let system: String?
        let tools: [ToolDefinition]?
        let messages: [Message]

        struct Message: Codable {
            let role: String
            let content: MessageContent

            enum MessageContent: Codable {
                case text(String)
                case blocks([ContentBlock])

                func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .text(let str):
                        try container.encode(str)
                    case .blocks(let blocks):
                        try container.encode(blocks)
                    }
                }

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let str = try? container.decode(String.self) {
                        self = .text(str)
                    } else {
                        self = .blocks(try container.decode([ContentBlock].self))
                    }
                }
            }
        }
    }

    struct ContentBlock: Codable {
        let type: String
        var text: String?
        var id: String?
        var name: String?
        var input: [String: AnyCodable]?
        var tool_use_id: String?
        var content: String?
    }

    struct ToolDefinition: Encodable {
        let name: String
        let description: String
        let input_schema: InputSchema

        struct InputSchema: Encodable {
            let type: String
            let properties: [String: PropertySchema]
            let required: [String]?
        }

        struct PropertySchema: Encodable {
            let type: String
            let description: String?
            let `enum`: [String]?

            enum CodingKeys: String, CodingKey {
                case type, description
                case `enum`
            }
        }
    }

    struct MessagesResponse: Decodable {
        let id: String
        let content: [ResponseContentBlock]
        let stop_reason: String?

        struct ResponseContentBlock: Decodable {
            let type: String
            var text: String?
            var id: String?
            var name: String?
            var input: [String: AnyCodable]?
        }
    }

    func sendMessages(
        system: String?,
        messages: [MessagesRequest.Message],
        tools: [ToolDefinition]?
    ) async throws -> MessagesResponse {
        let request = MessagesRequest(
            model: model,
            max_tokens: 4096,
            system: system,
            tools: tools,
            messages: messages
        )

        var urlRequest = URLRequest(url: URL(string: baseURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ClaudeAPIError.requestFailed(errorBody)
        }

        return try JSONDecoder().decode(MessagesResponse.self, from: data)
    }

    enum ClaudeAPIError: Error {
        case requestFailed(String)
        case noResponse
    }
}

// A simple type-erased Codable wrapper for JSON values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal.map { $0.value }
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intVal = value as? Int {
            try container.encode(intVal)
        } else if let doubleVal = value as? Double {
            try container.encode(doubleVal)
        } else if let boolVal = value as? Bool {
            try container.encode(boolVal)
        } else if let stringVal = value as? String {
            try container.encode(stringVal)
        } else if let arrayVal = value as? [Any] {
            try container.encode(arrayVal.map { AnyCodable($0) })
        } else if let dictVal = value as? [String: Any] {
            try container.encode(dictVal.mapValues { AnyCodable($0) })
        } else {
            try container.encodeNil()
        }
    }

    var stringValue: String? { value as? String }
    var intValue: Int? { value as? Int }
    var doubleValue: Double? { value as? Double }
    var boolValue: Bool? { value as? Bool }
}
