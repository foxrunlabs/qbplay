/// Music symbols that alter the pitch of a given note.
enum Accidental: Int, CustomStringConvertible {
    /// Lower the pitch by a half-step.
    case flat = -1
    
    /// Normal pitch.
    case none = 0
    
    /// Raise the pitch by a half-step.
    case sharp = 1
    
    // MARK: - Custom String Convertible
    var description: String {
        switch self {
        case .flat:
            "-"
        case .none:
            ""
        case .sharp:
            "+"
        }
    }
}
