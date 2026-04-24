import Foundation

enum MMLError: LocalizedError {
    /// An indication that there is an invalid MML command.
    /// - Parameters:
    ///     - command: Character represeting invalid command.
    ///     - column: Column number inside MML string.
    case invalidCommand(_ command: Character, column: Int)
    
    /// An indication that there is an invalid note length.
    case invalidLength
    
    /// An indication that there is an invalid named note.
    case invalidNamedNote
    
    /// An indication that there is an invalid numbered note.
    case invalidNumberedNote
    
    /// An indication that there is an invalid octave.
    case invalidOctave
    
    /// An indication that there is an invalid rest.
    case invalidRest
    
    /// An indication that there is an invalid tempo.
    case invalidTempo
    
    // MARK: - Localized Error
    var errorDescription: String? {
        switch self {
        case let .invalidCommand(_, column):
            "Invalid MML command at column \(column)."
        case .invalidLength:
            "Invalid note length."
        case .invalidNamedNote:
            "Invalid named note."
        case .invalidNumberedNote:
            "Invalid numbered note."
        case .invalidOctave:
            "Invalid octave."
        case .invalidRest:
            "Invalid rest."
        case .invalidTempo:
            "Invalid tempo."
        }
    }
}
