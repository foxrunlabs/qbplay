import Foundation

/// A representation of a musical note pitch.
struct Pitch: CustomStringConvertible {
    let name: NoteName
    let accidental: Accidental
    let octave: Int
    let frequency: Hertz
    
    /// Chromatic scale representing C, C#, D ... A#, and B.
    private static let chromaticScale: [(name: NoteName, accidental: Accidental)] = [
        (.c, .none),
        (.c, .sharp),
        (.d, .none),
        (.d, .sharp),
        (.e, .none),
        (.f, .none),
        (.f, .sharp),
        (.g, .none),
        (.g, .sharp),
        (.a, .none),
        (.a, .sharp),
        (.b, .none),
    ]
    
    /// Semitone number for A4.
    private static let a4Semitone = 4 * 12 + NoteName.a.semitoneOffset
    
    // MARK: - Initializers
    
    /// Creates a pitch for a named note.
    /// - Parameters:
    ///   - name: A value in the range A to G representing a note.
    ///   - accidental: The accidental symbol for the note.
    ///   - octave: A value in the range of 0 to 8 representing an octave for the note. Middle C is at the beginning of octave 3.
    init(name: NoteName, accidental: Accidental = .none, octave: Int) throws {
        // A semitone is computed by calculating the octave base, adding the note offset, and
        // adjusting for accidental.
        let semitone = name.semitoneOffset + octave * 12 + accidental.rawValue
        self.name = name
        self.accidental = accidental
        self.octave = octave
        self.frequency = 440.0 * pow(2.0, Double(semitone - Self.a4Semitone) / 12.0)
    }
    
    /// Create a pitch for a numbered note.
    /// - Parameter noteNumber: A value in the range of 1 to 84 that represents a note. A value of 1 represents C0.
    init(noteNumber: Int) throws {
        guard noteNumber >= 1 && noteNumber <= 84 else {
            throw MMLError.invalidNumberedNote(noteNumber)
        }
        
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
}


// MARK: - Custom String Convertible
extension Pitch {
    var description: String { "\(name)\(accidental)\(octave)" }
}
