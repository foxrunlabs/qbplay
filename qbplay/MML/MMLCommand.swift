/// Music Macro Language commands.
enum MMLCommand: CustomStringConvertible {
    /// Set articulation of each note.
    /// - Parameter articulation: The playing technique for all following notes.
    case articulation(_ articulation: Articulation)
    
    /// Play a named note.
    /// - Parameters:
    ///     - pitchClass: A value in the range A to G representing the pitch class.
    ///     - accidental: The accidental symbol for the note.
    ///     - length: An optional value in the range of 1 to 64 representing the length of the note.
    ///     - dots: A value representing the number of sustain dots for the note.
    case namedNote(_ pitchClass: PitchClass, accidental: Accidental, length: Int?, dots: Int)
    
    /// Set the length of each note.
    /// - Parameter length: A value in the range of 1 to 64 representing the length of each note. A value of 1 represents a whole
    /// note, 2 is a half note, 4 is a quarter note, and so on.
    case noteLength(_ length: Int)
    
    /// Play a numbered note.
    /// - Parameters:
    ///     - number: A value in the range of 0 to 84 that represents the note. A value of 0 represents a rest, and audible notes start
    ///     at 1, representing C2.
    ///     - dots: An optional value representing the number of sustain dots for the note.
    case numberedNote(_ number: Int, dots: Int)
    
    /// Set the current octave.
    /// - Parameter octave: A value in the range of 0 to 6 representing an octave for each note. Middle C is at the beginning of
    /// octave 2.
    case octave(_ octave: Int) // TODO: HOW SHOULD THIS BE REPRESENTED FOR NORMAL OR QBASIC
    
    /// Shift the current octave down.
    case octaveDown
    
    /// Shift the current octave up.
    case octaveUp
    
    /// Rest.
    /// - Parameters:
    ///     - length: A value in the range of 1 to 64 representing the length of the rest.
    ///     - dots: A value representing the number of sustain dots for the rest.
    case rest(length: Int, dots: Int)
    
    /// Set the tempo.
    /// - Parameter tempo: A value in the range of 32 to 255 representing the number of quarter notes per minute.
    case tempo(_ tempo: Int)
}


// MARK: - CustomStringConvertible
extension MMLCommand {
    var description: String {
        switch self {
        case let .articulation(articulation):
            "M\(articulation)"
        case let .namedNote(pitchClass, accidental: accidental, length: length, dots: dots):
            "\(pitchClass)\(accidental)\(length, default: "")" + String(repeating: ".", count: dots)
        case let .noteLength(length):
            "L\(length)"
        case let .numberedNote(number, dots: dots):
            "N\(number)" + String(repeating: ".", count: dots)
        case let .octave(octave):
            "O\(octave)"
        case .octaveDown:
            "<"
        case .octaveUp:
            ">"
        case let .rest(length, dots: dots):
            "P\(length)" + String(repeating: ".", count: dots)
        case let .tempo(tempo):
            "T\(tempo)"
        }
    }
}
