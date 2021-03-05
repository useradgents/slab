import Foundation

/// A protocol for grouping functionality common to all Encoders
protocol CodingEncoder {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
    func encode<T>(_ value: T, to url: URL) throws where T: Encodable
}

/// A protocol for grouping functionality common to all Decoders
protocol CodingDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable
    func decode<T>(_ type: T.Type, at url: URL) throws -> T where T: Decodable
}

extension JSONDecoder: CodingDecoder {
    public static var shared: JSONDecoder = {
        let dec = JSONDecoder()
        return dec
    }()
    
    /// Decodes an instance of the indicated type from data at the given URL
    func decode<T>(_ type: T.Type, at url: URL) throws -> T where T : Decodable {
        let data = try Data(contentsOf: url)
        return try decode(T.self, from: data)
    }
}

extension JSONEncoder: CodingEncoder {
    public static var shared: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()
    
    /// Encodes an instance of the indicated type and writes it to the given URL
    func encode<T>(_ value: T, to url: URL) throws where T: Encodable {
        let data = try encode(value)
        try data.write(to: url, options: [.atomic])
    }
}

/* Also applicable to MessagePack, should you include it: */

//extension MessagePackDecoder: CodingDecoder {
//    public static var shared: MessagePackDecoder = {
//        let dec = MessagePackDecoder()
//        return dec
//    }()
//
//    func decode<T>(_ type: T.Type, at url: URL) throws -> T where T : Decodable {
//        let data = try Data(contentsOf: url)
//        return try decode(T.self, from: data)
//    }
//}
//
//extension MessagePackEncoder: CodingEncoder {
//    public static var shared: MessagePackEncoder = {
//        let enc = MessagePackEncoder()
//        return enc
//    }()
//
//    func encode<T>(_ value: T, to url: URL) throws where T: Encodable {
//        let data = try encode(value)
//        try data.write(to: url, options: [.atomic])
//    }
//}
