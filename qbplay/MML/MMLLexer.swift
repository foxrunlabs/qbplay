/// An object that lexes MML command strings.
struct MMLLexer {
    /// Lex a tune string.
    /// - Parameter tune: A string representing MML commands.
    /// - Returns: A sequence of MML commands.
    /// - Throws: If there is an error lexing, this method throws a LexerError or PitchError.
    static func lex(_ tune: String) throws -> [MMLCommand] {
        // Remove any whitespace in the string and convert to uppercase
        var input = Array(tune.filter { !$0.isWhitespace }.uppercased())[...]
        var output: [MMLCommand] = []
        
        while let c = input.popFirst() {
            switch c {
            // Named note
            case "A"..."G":
                let accidental = readAccidental(from: &input)
                let length = readNumber(from: &input)
                let dots = readDots(from: &input)
                output.append(.namedNote(c, accidental: accidental, length: length, dots: dots))
            
            // Note length
            case "L":
                guard let length = readNumber(from: &input) else {
                    throw LexerError.invalidNoteLength
                }
                
                output.append(.noteLength(length))
            
            // Articulation
            case "M":
                guard let music = input.popFirst() else { throw LexerError.invalidArticulation }
                let articulation: Articulation
                
                switch music {
                case "B", "F":
                    // These represent background and foreground in QBasic. We can ignore them.
                    continue
                case "L":
                    articulation = .legato
                case "N":
                    articulation = .normal
                case "S":
                    articulation = .staccato
                default:
                    throw LexerError.invalidArticulation
                }
                
                output.append(.articulation(articulation))
            
            // Numbered note
            case "N":
                guard let number = readNumber(from: &input) else {
                    throw LexerError.invalidNumberedNote
                }
                
                let dots = readDots(from: &input)
                output.append(.numberedNote(number, dots: dots))
            
            // Octave
            case "O":
                guard let octave = readNumber(from: &input) else {
                    throw LexerError.invalidOctave
                }
                
                output.append(.octave(octave))
            
            // Rest
            case "P":
                guard let length = readNumber(from: &input) else {
                    throw LexerError.invalidRest
                }
                
                let dots = readDots(from: &input)
                output.append(.rest(length: length, dots: dots))
            
            // Tempo
            case "T":
                guard let tempo = readNumber(from: &input) else {
                    throw LexerError.invalidTempo
                }
                
                output.append(.tempo(tempo))
            
            // Shift octave down
            case "<":
                output.append(.octaveDown)
            
            // Shift octave up
            case ">":
                output.append(.octaveUp)
            
            // Unknown command
            default:
                throw LexerError.unknownCommand
            }
        }
        
        return output
    }
    
    /// Read an accidental character for a note.
    /// - Parameter input: A string representing MML commands.
    /// - Returns: The accidental for the note.
    private static func readAccidental(from input: inout ArraySlice<String.Element>) -> Accidental {
        guard let c = input.first, "#+-".contains(c) else { return .none }
        input.removeFirst()
        
        return switch c {
        case "#", "+":
            .sharp
        case "-":
            .flat
        default:
            // We should never get here.
            .none
        }
    }
    
    /// Read the number of sustain dots for a note or rest.
    /// - Parameter input: A string representing MML commands.
    /// - Returns: The number of sustain dots for the note or rest.
    private static func readDots(from input: inout ArraySlice<String.Element>) -> Int {
        var value = 0
        
        while let c = input.first, c == "." {
            value += 1
            input.removeFirst()
        }
        
        return value
    }
    
    /// Read a number.
    /// - Parameter input: A string representing MML commands..
    /// - Returns: An integer value, or `nil` if no number present.
    private static func readNumber(from input: inout ArraySlice<String.Element>) -> Int? {
        var value: Int?
        
        while let c = input.first, let digit = c.wholeNumberValue {
            value = (value ?? 0) * 10 + digit
            input.removeFirst()
        }
        
        return value
    }
}


// MARK: - Lexer Error
extension MMLLexer {
    /// An error that occurs when lexing a MML command string.
    enum LexerError: Error {
        /// An indication that there is an invalid note length.
        case invalidNoteLength
        
        /// An indication that there is an invalid numbered note.
        case invalidNumberedNote
        
        /// An indication that there is an invalid octave.
        case invalidOctave
        
        /// An indication that there is an invalid rest.
        case invalidRest
        
        /// An indication that there is an invalid articulation.
        case invalidArticulation
        
        /// An indication that there is an invalid tempo.
        case invalidTempo
        
        /// An indication that there is an unknown MML command.
        case unknownCommand
    }
}
