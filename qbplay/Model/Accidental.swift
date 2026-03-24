enum Accidental: Int, CustomStringConvertible {
    case flat = -1
    case none = 0
    case sharp = 1
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .flat:
            "♭"
        case .none:
            ""
        case .sharp:
            "♯"
        }
    }
}
