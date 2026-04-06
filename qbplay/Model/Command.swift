/// Music Macro Language commands.
enum MMLCommand: CustomStringConvertible {
    /// Set articulation of each note.
    /// - Parameters:
    ///     - articulation: The playing technique for all following notes.
    case articulation(_ articulation: Articulation)
    
    /// Play a named note.
    /// - Parameters:
    ///     - name: A value in the range A to G representing the note.
    ///     - accidental: The accidental symbol for the note.
    ///     - length: An optional value in the range of 1 to 64 representing the length of the note.
    ///     - dots: A value representing the number of sustain dots for the note.
    case namedNote(_ name: Character, accidental: Accidental, length: Int?, dots: Int)
    
    /// Set the length of each note.
    /// - Parameters:
    ///     - length: A value in the range of 1 to 64 representing the length of each note. A value of 1 represents a whole note, 2 is
    ///     a half note, 4 is a quarter note, and so on.
    case noteLength(_ length: Int)
    
    /// Play a numbered note.
    /// - Parameters:
    ///     - number: A value in the range of 0 to 84 that represents the note. A value of 0 represents a rest, and audible notes start
    ///     at 1, representing C0.
    ///     - dots: An optional value representing the number of sustain dots for the note.
    case numberedNote(_ number: Int, dots: Int)
    
    /// Set the current octave.
    /// - Parameters:
    ///     - octave: A value in the range of 0 to 8 representing an octave for each note. Middle C is at the beginning of octave 3.
    case octave(_ octave: Int)
    
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
    /// - Parameters:
    ///     - tempo: A value in the range of 32 to 255 representing the number of quarter notes per minute.
    case tempo(_ tempo: Int)
}


// MARK: - CustomStringConvertible
extension MMLCommand {
    var description: String {
        switch self {
        case .articulation(let articulation):
            "M\(articulation)"
        case .namedNote(let name, accidental: let accidental, length: let length, dots: let dots):
            "\(name)\(accidental)\(length, default: "")" + String(repeating: ".", count: dots)
        case .noteLength(let length):
            "L\(length)"
        case .numberedNote(let number, dots: let dots):
            "N\(number)" + String(repeating: ".", count: dots)
        case .octave(let octave):
            "O\(octave)"
        case .octaveDown:
            "<"
        case .octaveUp:
            ">"
        case .rest(let length, dots: let dots):
            "P\(length)" + String(repeating: ".", count: dots)
        case .tempo(let tempo):
            "T\(tempo)"
        }
    }
}
