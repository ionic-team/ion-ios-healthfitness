import Foundation

extension String {
    public func decode<T: Decodable>() -> T? {
        guard let data = self.data(using: .utf8), let result = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        return result
    }
}

extension Encodable {
    public func encode() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let data = try? encoder.encode(self), let res = String(data: data, encoding: .utf8) else { return "" }
        return res
    }
}
