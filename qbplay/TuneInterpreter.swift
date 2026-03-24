struct TuneInterpreter {
    func interpret(_ commands: [MMLCommand]) throws -> [TuneEvent] {
        var state: TuneState = TuneState()
        var events: [TuneEvent] = []
        
        for command in commands {
            switch command {
            case .noteLength(let length):
                state.noteLength = length
            case .namedNote(let name, let accidental, let length, let dots):
                let pitch = try Pitch(name: name, accidental: accidental, octave: state.octave)
                let note = Note(
                    pitch: pitch,
                    tempo: state.tempo,
                    length: length ?? state.noteLength,
                    dots: dots,
                    technique: state.technique
                )
                
                events.append(.note(note))
            case .numberedNote(let number, let dots):
                if number == 0 {
                    let rest = Rest(tempo: state.tempo, length: state.noteLength, dots: dots)
                    events.append(.rest(rest))
                } else {
                    let pitch = try Pitch(noteNumber: number)
                    let note = Note(
                        pitch: pitch,
                        tempo: state.tempo,
                        length: state.noteLength,
                        dots: dots,
                        technique: state.technique
                    )
                    
                    events.append(.note(note))
                }
            case .octave(let octave):
                state.octave = octave
            case .octaveDown:
                state.octave = max(0, state.octave - 1)
            case .octaveUp:
                state.octave = min(state.octave + 1, 8)
            case .rest(let length, let dots):
                let rest = Rest(tempo: state.tempo, length: length, dots: dots)
                events.append(.rest(rest))
            case .technique(let technique):
                state.technique = technique
            case .tempo(let tempo):
                state.tempo = tempo
            }
        }
        
        return events
    }
}
