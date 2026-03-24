import Foundation

struct Pitch: CustomStringConvertible {
    let name: Character
    let accidental: Accidental
    let octave: Int
    let frequency: Hertz
    
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
    
    private static let a4Semitone = 4 * 12 + 9
    
    // MARK: - Initializers
    init(name: Character, accidental: Accidental = .none, octave: Int) throws {
        guard var semitone = Self.baseOffset(for: name) else { throw PitchError.invalidNoteName }
        semitone += octave * 12 + accidental.rawValue
        
        self.name = name
        self.accidental = accidental
        self.octave = octave
        self.frequency = 440.0 * pow(2.0, Double(semitone - Self.a4Semitone) / 12.0)
    }
    
    init(noteNumber: Int) throws {
        guard noteNumber >= 1 && noteNumber <= 84 else { throw PitchError.invalidNoteNumber }
        let semitone = noteNumber - 1
        let pitchClass = Self.chromaticScale[semitone % 12]
        
        self.name = pitchClass.name
        self.accidental = pitchClass.accidental
        self.octave = semitone / 12
        self.frequency = 440.0 * pow(2.0, Double(semitone - Self.a4Semitone) / 12.0)
    }
    
    // MARK: - Methods
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
    enum PitchError: Error {
        case invalidNoteName
        case invalidNoteNumber
    }
}


// MARK: - Custom String Convertible
extension Pitch {
    var description: String { "\(name)\(accidental)\(octave)" }
}
