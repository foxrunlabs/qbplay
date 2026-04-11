/// An object that lexes MML command strings.
struct MMLLexer {
    /// Lex a tune string.
    /// - Parameter tune: A string representing MML commands.
    /// - Returns: A sequence of MML commands.
    /// - Throws: If there is an error lexing, this method throws a LexerError or PitchError.
    static func lex(_ tune: String) throws -> [MMLCommand] {
        // Remove any whitespace in the string and convert to lowercase
        var input = Array(tune.lowercased())[...]
        var output: [MMLCommand] = []
        
        while let c = input.popFirst() {
            switch c {
            // Named note
            case "a"..."g":
                guard let name = NoteName(rawValue: c) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                let accidental = readAccidental(from: &input)
                let length = readNumber(from: &input)
                let dots = readDots(from: &input)
                output.append(.namedNote(name, accidental: accidental, length: length, dots: dots))
            
            // Note length
            case "l":
                guard let length = readNumber(from: &input) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                output.append(.noteLength(length))
            
            // Articulation
            case "m":
                guard let music = input.popFirst() else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                let articulation: Articulation
                
                switch music {
                case "b", "f":
                    // These represent background and foreground in QBasic. We can ignore them.
                    continue
                case "l":
                    articulation = .legato
                case "n":
                    articulation = .normal
                case "s":
                    articulation = .staccato
                default:
                    // Already popped the second character, so adjust column to M command.
                    throw MMLError.invalidCommand(c, column: input.startIndex - 1)
                }
                
                output.append(.articulation(articulation))
            
            // Numbered note
            case "n":
                guard let number = readNumber(from: &input) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                let dots = readDots(from: &input)
                output.append(.numberedNote(number, dots: dots))
            
            // Octave
            case "o":
                guard let octave = readNumber(from: &input) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                output.append(.octave(octave))
            
            // Rest
            case "p":
                guard let length = readNumber(from: &input) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                let dots = readDots(from: &input)
                output.append(.rest(length: length, dots: dots))
            
            // Tempo
            case "t":
                guard let tempo = readNumber(from: &input) else {
                    throw MMLError.invalidCommand(c, column: input.startIndex)
                }
                
                output.append(.tempo(tempo))
            
            // Shift octave down
            case "<":
                output.append(.octaveDown)
            
            // Shift octave up
            case ">":
                output.append(.octaveUp)
            
            // Skip whitespace. Not filtered from input in order to preserve indices.
            case let c where c.isWhitespace:
                continue
            
            // Unknown command
            default:
                throw MMLError.invalidCommand(c, column: input.startIndex)
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

