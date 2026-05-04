import Foundation

extension Bundle {
    /// Find and decode a JSON file from a bundle.
    /// - Parameter from: filename of JSON from which to decode.
    /// - Returns: decoded JSON.
    func decode<T: Decodable>(from filename: String) -> [T] {
        guard
            let url = url(forResource: filename, withExtension: nil),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("Failed to load \(filename) in bundle.")
        }
        
        do {
            return try JSONDecoder().decode([T].self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(filename) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(filename) from bundle due to type mismatch - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(filename) from bundle due to missing \(type) value - \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(filename) from bundle because it appears to be invalid JSON.")
        } catch {
            fatalError("Failed to decode \(filename) from bundle: \(error.localizedDescription)")
        }
    }
}
