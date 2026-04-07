/// Musical note names.
enum NoteName: Character, CustomStringConvertible {
    case c = "c"
    case d = "d"
    case e = "e"
    case f = "f"
    case g = "g"
    case a = "a"
    case b = "b"
    
    // MARK: - Computed Properties
    
    /// The offset inside an octave for each note.
    var semitoneOffset: Int {
        switch self {
        case .c: 0
        case .d: 2
        case .e: 4
        case .f: 5
        case .g: 7
        case .a: 9
        case .b: 11
        }
    }
    
    // MARK: - Custom String Convertible
    var description: String { String(self.rawValue).uppercased() }
}
