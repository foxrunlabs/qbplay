import Foundation

/// A representation of a musical note pitch on a 108-key piano.
struct Pitch: CustomStringConvertible {
    let pitchClass: PitchClass
    let accidental: Accidental
    let octave: Int
    let frequency: Hertz
    
    /// Maps semitone offsets within an octave to pitch spellings.
    private static let semitoneMap: [(pitchClass: PitchClass, accidental: Accidental)] = [
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
    
    private static let semitonesPerOctave = semitoneMap.count
    private static let validSemitoneRange = 0...107
    
    // MARK: - Initializers
    
    /// Creates a pitch for a named note.
    /// - Parameters:
    ///   - pitchClass: The pitch class for the note.
    ///   - accidental: The accidental symbol for the note.
    ///   - octave: A value in the range `0...8` representing the octave for the note.
    /// - Returns: A new `Pitch` instance, or `nil` if it's not possible.
    init?(pitchClass: PitchClass, accidental: Accidental = .none, octave: Int) {
        let semitone = pitchClass.semitoneOffset + accidental.rawValue + octave *
            Self.semitonesPerOctave
        self.init(semitone: semitone)
    }
    
    /// Creates a pitch for a numbered note.
    /// - Parameter noteNumber: A value in the range `-8...99` representing a note on a 108-key piano.
    /// `-8` represents C0. `99` represents B8.
    /// - Returns: A new `Pitch` instance, or `nil` if it's not possible.
    init?(noteNumber: Int) {
        let semitone = noteNumber + 8   // normalize to semitone 0 = C0
        self.init(semitone: semitone)
    }
    
    /// Creates a pitch for a semitone.
    /// - Parameter semitone: A value in the range `0...107` representing a semitone on a 108-key piano.
    /// `0` represents C0. `107` represents B8.
    /// - Returns: A new `Pitch` instance, or `nil` if it's not possible.
    private init?(semitone: Int) {
        guard Self.validSemitoneRange.contains(semitone) else { return nil }
        
        let (pitchClass, accidental) = Self.semitoneMap[semitone % Self.semitonesPerOctave]
        self.pitchClass = pitchClass
        self.accidental = accidental
        self.octave = semitone / Self.semitonesPerOctave
        
        // Pitch is computed using A4 as a reference.
        // pitch = (440 Hz) * 2 ^ ((semitone - A4) / 12)
        let a4Frequency = 440.0
        let a4Semitone = PitchClass.a.semitoneOffset + 4 * Self.semitonesPerOctave
        self.frequency = a4Frequency * pow(2.0, Double(semitone - a4Semitone) /
            Double(Self.semitonesPerOctave))
    }
}


// MARK: - Custom String Convertible
extension Pitch {
    var description: String { "\(pitchClass)\(accidental)\(octave)" }
}
