/// An object that interprets MML commands.
struct MMLInterpreter {
    /// Interpret MML commands..
    /// - Parameter commands: A sequence of MML commands.
    /// - Returns: A sequence of playable music events..
    /// - Throws: If there is an error interpreting, this method throws a PitchError.
    static func interpret(_ commands: [MMLCommand]) throws -> [MusicEvent] {
        var state = State()
        var events: [MusicEvent] = []
        
        for command in commands {
            switch command {
            // Articulation
            case .articulation(let articulation):
                state.articulation = articulation
            
            // Named note
            case .namedNote(let name, let accidental, let length, let dots):
                let pitch = try Pitch(name: name, accidental: accidental, octave: state.octave)
                let note = Note(
                    pitch: pitch,
                    tempo: state.tempo,
                    length: length ?? state.noteLength,
                    dots: dots,
                    articulation: state.articulation
                )
                
                events.append(note)
            
            // Note length
            case .noteLength(let length):
                state.noteLength = length
            
            // Numbered note, or rest if number is 0.
            case .numberedNote(let number, let dots):
                if number == 0 {
                    let rest = Rest(tempo: state.tempo, length: state.noteLength, dots: dots)
                    events.append(rest)
                } else {
                    let pitch = try Pitch(noteNumber: number)
                    let note = Note(
                        pitch: pitch,
                        tempo: state.tempo,
                        length: state.noteLength,
                        dots: dots,
                        articulation: state.articulation
                    )
                    
                    events.append(note)
                }
            
            // Octave
            case .octave(let octave):
                state.octave = octave
            
            // Shift octave down
            case .octaveDown:
                state.octave = max(0, state.octave - 1)
            
            // Shift octave up
            case .octaveUp:
                state.octave = min(state.octave + 1, 8)
            
            // Rest
            case .rest(let length, let dots):
                let rest = Rest(tempo: state.tempo, length: length, dots: dots)
                events.append(rest)
            
            // Tempo
            case .tempo(let tempo):
                state.tempo = tempo
            }
        }
        
        return events
    }
}


// MARK: - Interpreter State
extension MMLInterpreter {
    /// State of the MML interpreter, representing note length, articulation, octave, and tempo.
    struct State {
        /// Length of each note. Default is 4, representing a quarter note.
        var noteLength: Int = 4
        
        /// Articulation of each note. Default is `normal`.
        var articulation: Articulation = .normal
        
        /// Octave for each note. Default is 4.
        var octave: Int = 4
        
        /// Tempo for each note in quarter notes per minute. Default is 120.
        var tempo: Int = 120
    }
}
