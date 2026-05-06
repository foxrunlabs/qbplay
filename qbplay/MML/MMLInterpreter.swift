/// An object that interprets MML commands.
enum MMLInterpreter {
    /// State of the MML interpreter, representing note length, articulation, octave, and tempo.
    struct State {
        /// Length of each note. Default is `4`, representing a quarter note.
        var noteLength: Int = 4
        
        /// Articulation of each note. Default is `normal`.
        var articulation: Articulation = .normal
        
        /// Octave for each note. Default is `6`, which represents QBasic octave `4`.
        var octave: Int = 6
        
        /// Tempo for each note in quarter notes per minute. Default is `120`.
        var tempo: Int = 120
    }
    
    // MARK: - Properties
    private static let validOctaveRange = 0...6
    private static let validLengthRange = 1...64
    private static let validNoteRange = 0...84
    private static let validTempoRange = 32...255
    
    /// Interpret MML commands..
    /// - Parameter commands: A sequence of MML commands.
    /// - Returns: A sequence of playable music events.
    /// - Throws: If there is an error interpreting, this method throws a PitchError.
    static func interpret(_ commands: [MMLCommand]) throws -> [MusicEvent] {
        var state = State()
        var events: [MusicEvent] = []
        
        for command in commands {
            switch command {
            // Articulation
            case let .articulation(articulation):
                state.articulation = articulation
            
            // Named note
            case let .namedNote(pitchClass, accidental, length, dots):
                if let length, !Self.validLengthRange.contains(length) {
                    throw MMLError.invalidNamedNote
                }
                
                guard
                    let pitch = Pitch(
                        pitchClass: pitchClass,
                        accidental: accidental,
                        octave: state.octave
                    ),
                    let note = Note(
                        pitch: pitch,
                        tempo: state.tempo,
                        articulation: state.articulation,
                        length: length ?? state.noteLength,
                        dots: dots
                    )
                else {
                    throw MMLError.invalidNamedNote
                }
                
                events.append(note)
            
            // Note length
            case let .noteLength(length):
                guard Self.validLengthRange.contains(length) else { throw MMLError.invalidLength }
                state.noteLength = length
            
            // Numbered note, or rest if number is `0`.
            case let .numberedNote(number, dots):
                guard Self.validNoteRange.contains(number) else {
                    throw MMLError.invalidNumberedNote
                }
                
                if number == 0 {
                    guard
                        let rest = Rest(tempo: state.tempo, length: state.noteLength, dots: dots)
                    else {
                        throw MMLError.invalidNumberedNote
                    }
                    
                    events.append(rest)
                } else {
                    let qbasicNoteNumber = number + 15  // QBasic is two octaves higher than normal
                    
                    guard
                        let pitch = Pitch(noteNumber: qbasicNoteNumber),
                        let note = Note(
                            pitch: pitch,
                            tempo: state.tempo,
                            articulation: state.articulation,
                            length: state.noteLength,
                            dots: dots
                        )
                    else {
                        throw MMLError.invalidNumberedNote
                    }
                    
                    events.append(note)
                }
            
            // Octave
            case let .octave(octave):
                guard Self.validOctaveRange.contains(octave) else { throw MMLError.invalidOctave }
                state.octave = octave + 2   // QBasic is 2 octaves higher than normal
            
            // Shift octave down
            case .octaveDown:
                state.octave = max(Self.validOctaveRange.lowerBound + 2, state.octave - 1)
            
            // Shift octave up
            case .octaveUp:
                state.octave = min(state.octave + 1, Self.validOctaveRange.upperBound + 2)
            
            // Rest
            case let .rest(length, dots):
                guard
                    Self.validLengthRange.contains(length),
                    let rest = Rest(tempo: state.tempo, length: length, dots: dots)
                else {
                    throw MMLError.invalidRest
                }
                
                events.append(rest)
            
            // Tempo
            case let .tempo(tempo):
                guard Self.validTempoRange.contains(tempo) else { throw MMLError.invalidTempo }
                state.tempo = tempo
            }
        }
        
        return events
    }
}
