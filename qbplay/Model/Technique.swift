enum Technique: Double, CustomStringConvertible {
    case staccato = 0.75
    case normal = 0.875
    case legato = 1.0
    
    // MARK: - CustomStringConvertible
    var description: String {
        switch self {
        case .legato:
            "Legato"
        case .normal:
            "Normal"
        case .staccato:
            "Staccato"
        }
    }
}
