import Observation

@Observable
final class TuneLexer {
    // MARK: - Methods
    func lex(tune: String) throws -> [MMLCommand] {
        var input = Array(tune.filter { !$0.isWhitespace }.uppercased())[...]
        var output: [MMLCommand] = []
        
        while let c = input.popFirst() {
            switch c {
            case "A"..."G":
                let accidental = readAccidental(from: &input)
                let length = readNumber(from: &input)
                
                if let length, length < 1 || length > 64 {
                    throw LexerError.invalidNoteLength
                }
                
                let dots = readDots(from: &input)
                
                output.append(.namedNote(c, accidental: accidental, length: length, dots: dots))
            case "L":
                guard
                    let length = readNumber(from: &input),
                    length >= 1 && length <= 64
                else {
                    throw LexerError.invalidNoteLength
                }
                
                output.append(.noteLength(length))
            case "M":
                guard let music = input.popFirst() else { throw LexerError.invalidMusic }
                var technique: Technique
                
                switch music {
                case "B", "F":
                    continue
                case "L":
                    technique = .legato
                case "N":
                    technique = .normal
                case "S":
                    technique = .staccato
                default:
                    throw LexerError.invalidTechnique
                }
                
                output.append(.technique(technique))
            case "N":
                guard
                    let number = readNumber(from: &input),
                    number >= 0 && number <= 84
                else {
                    throw LexerError.invalidNote
                }
                
                let dots = readDots(from: &input)
                
                output.append(.numberedNote(number, dots: dots))
            case "O":
                guard
                    let octave = readNumber(from: &input),
                    octave >= 0 && octave <= 8
                else {
                    throw LexerError.invalidOctave
                }
                
                output.append(.octave(octave))
            case "P", "R":
                guard
                    let length = readNumber(from: &input),
                    length >= 1 && length <= 64
                else {
                    throw LexerError.invalidRest
                }
                
                let dots = readDots(from: &input)
                
                output.append(.rest(length: length, dots: dots))
            case "T":
                guard
                    let tempo = readNumber(from: &input),
                    tempo >= 32 && tempo <= 255
                else {
                    throw LexerError.invalidTempo
                }
                
                output.append(.tempo(tempo))
            case "<":
                output.append(.octaveDown)
            case ">":
                output.append(.octaveUp)
            default:
                throw LexerError.invalidTune
            }
        }
        
        return output
    }
    
    private func readAccidental(from input: inout ArraySlice<String.Element>) -> Accidental {
        guard let c = input.first, "#+-".contains(c) else { return .none }
        input.removeFirst()
        
        return switch c {
        case "#", "+":
            .sharp
        case "-":
            .flat
        default:
            .none
        }
    }
    
    private func readDots(from input: inout ArraySlice<String.Element>) -> Int? {
        var value: Int?
        
        while let c = input.first, c == "." {
            value = (value ?? 0) + 1
            input.removeFirst()
        }
        
        return value
    }
    
    private func readNumber(from input: inout ArraySlice<String.Element>) -> Int? {
        var value: Int?
        
        while let c = input.first, let digit = c.wholeNumberValue {
            value = (value ?? 0) * 10 + digit
            input.removeFirst()
        }
        
        return value
    }
}


// MARK: - Lexer Error
extension TuneLexer {
    enum LexerError: Error {
        case invalidMusic
        case invalidNoteLength
        case invalidNote
        case invalidOctave
        case invalidRest
        case invalidTechnique
        case invalidTempo
        case invalidTune
    }
}
