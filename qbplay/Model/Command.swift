enum MMLCommand {
    case namedNote(_ name: Character, accidental: Accidental, length: Int?, dots: Int?)
    case noteLength(Int)
    case numberedNote(_ number: Int, dots: Int?)
    case octave(Int)
    case octaveDown
    case octaveUp
    case rest(length: Int, dots: Int?)
    case technique(Technique)
    case tempo(Int)
}
