import Vapor

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

extension ContentConfiguration {
    static func configureAPI() {
        let encoder = JSONEncoder.apiEncoder
        let decoder = JSONDecoder.apiDecoder
        ContentConfiguration.global.use(encoder: encoder, for: .json)
        ContentConfiguration.global.use(decoder: decoder, for: .json)
    }
}
