import Foundation

/// A representation of a musical note pitch.
struct Pitch: CustomStringConvertible {
    let name: Character
    let accidental: Accidental
    let octave: Int
    let frequency: Hertz
    
    /// Chromatic scale representing C, C#, D ... A#, and B.
    private static let chromaticScale: [(name: Character, accidental: Accidental)] = [
        ("C", .none),
        ("C", .sharp),
        ("D", .none),
        ("D", .sharp),
        ("E", .none),
        ("F", .none),
        ("F", .sharp),
        ("G", .none),
        ("G", .sharp),
        ("A", .none),
        ("A", .sharp),
        ("B", .none),
    ]
    
    /// Semitone number for A4.
    private static let a4Semitone = 4 * 12 + 9
    
    // MARK: - Initializers
    
    /// Creates a pitch for a named note.
    /// - Parameters:
    ///   - name: A value in the range A to G representing a note.
    ///   - accidental: The accidental symbol for the note.
    ///   - octave: A value in the range of 0 to 8 representing an octave for the note. Middle C is at the beginning of octave 3.
    init(name: Character, accidental: Accidental = .none, octave: Int) throws {
        // A semitone is computed by calculating the octave base, adding the note offset, and
        // adjusting for accidental.
        guard var semitone = Self.baseOffset(for: name) else { throw PitchError.invalidNoteName }
        semitone += octave * 12 + accidental.rawValue
        
        self.name = name
        self.accidental = accidental
        self.octave = octave
        self.frequency = 440.0 * pow(2.0, Double(semitone - Self.a4Semitone) / 12.0)
    }
    
    /// Create a pitch for a numbered note.
    /// - Parameter noteNumber: A value in the range of 1 to 84 that represents a note. A value of 1 represents C0.
    init(noteNumber: Int) throws {
        guard noteNumber >= 1 && noteNumber <= 84 else { throw PitchError.invalidNoteNumber }
        
        // The numbered note MML command uses a value of 0 to represent a rest.
        let semitone = noteNumber - 1
        let pitchClass = Self.chromaticScale[semitone % 12]
        
        self.name = pitchClass.name
        self.accidental = pitchClass.accidental
        self.octave = semitone / 12
        
        // Pitch is computed using A4 as a reference.
        // pitch = (440 Hz) * 2 ^ ((semitone - A4) / 12)
        self.frequency = 440.0 * pow(2.0, Double(semitone - Self.a4Semitone) / 12.0)
    }
    
    // MARK: - Methods
    
    /// Calculate the offset inside an octave for each named note.
    /// - Parameter note: A value in the range A to G representing a note.
    /// - Returns: The offset value inside an octave.
    private static func baseOffset(for note: Character) -> Int? {
        switch note {
        case "C": 0
        case "D": 2
        case "E": 4
        case "F": 5
        case "G": 7
        case "A": 9
        case "B": 11
        default: nil
        }
    }
}


// MARK: - Pitch Error
extension Pitch {
    /// An error that occurs during the creation of a pitch.
    enum PitchError: Error {
        /// An indication that the note name is invalid.
        case invalidNoteName
        
        /// An indication that the note number is invalid.
        case invalidNoteNumber
    }
}


// MARK: - Custom String Convertible
extension Pitch {
    var description: String { "\(name)\(accidental)\(octave)" }
}
