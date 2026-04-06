/// Techniques defining how a note is played.
enum Articulation: Double, CustomStringConvertible {
    /// Each note plays three-quarters of one period.
    case staccato = 0.75
    
    /// Each note plays seven-eighths of one period.
    case normal = 0.875
    
    /// Each note plays the full period.
    case legato = 1.0
    
    // MARK: - CustomStringConvertible
    var description: String {
        switch self {
        case .staccato:
            "S"
        case .normal:
            "N"
        case .legato:
            "L"
        }
    }
}
