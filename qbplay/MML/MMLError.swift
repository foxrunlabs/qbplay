import Foundation

enum MMLError: LocalizedError {
    /// An indication that there is an invalid MML command.
    /// - Parameters:
    ///     - command: Character represeting invalid command.
    ///     - column: Column number inside MML string.
    case invalidCommand(_ command: Character, column: Int)
    
    /// An indication that there is an invalid note length.
    /// - Parameter length: Note length.
    case invalidLength(_ length: Int)
    
    /// An indication that there is an invalid numbered note.
    /// - Parameter number: Note number.
    case invalidNumberedNote(_ number: Int)
    
    /// An indication that there is an invalid octave.
    /// - Parameter octave: Octave number.
    case invalidOctave(_ octave: Int)
    
    /// An indication that there is an invalid tempo.
    /// - Parameter tempo: Tempo number.
    case invalidTempo(_ tempo: Int)
    
    // MARK: - Localized Error
    var errorDescription: String? {
        switch self {
        case let .invalidCommand(_, column):
            "Invalid MML command at column \(column)."
        case .invalidLength:
            "Invalid note length."
        case .invalidNumberedNote:
            "Invalid numbered note."
        case .invalidOctave:
            "Invalid octave."
        case .invalidTempo:
            "Invalid tempo."
        }
    }
    
    var failureReason: String? {
        switch self {
        case let .invalidCommand(command, _):
            "'\(command)' is not a valid MML command."
        case let .invalidLength(length):
            "'\(length)' is not a valid note length."
        case let .invalidNumberedNote(number):
            "'\(number)' is not a valid numbered note."
        case let .invalidOctave(octave):
            "'\(octave)' is not a valid octave."
        case let .invalidTempo(tempo):
            "'\(tempo)' is not a valid tempo."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCommand:
            "Make sure you only use valid MML commands."
        case .invalidLength:
            "Use a value between 1 and 64 for note length."
        case .invalidNumberedNote:
            "Use a value between 0 and 84 for numbered notes."
        case .invalidOctave:
            "Use a value between 0 and 6 for octave."
        case .invalidTempo:
            "Use a value between 32 and 255 for tempo."
        }
    }
}
