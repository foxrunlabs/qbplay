import Foundation

/// A representation of a rest.
struct Rest: MusicEvent {
    let tempo: Int
    let duration: Beat
    
    private static let validTempoRange = 32...255
    private static let validLengthRange = 1...64
    
    // MARK: - Initializers
    
    /// Creates a rest.
    /// - Parameters:
    ///   - tempo: A value in the range of `32...255` representing the number of quarter notes per minute.
    ///   - length: A value in the range of `1...64` representing the length of the rest.
    ///   - dots: A value representing the number of sustain dots for the rest.
    /// - Returns: A new `Rest` instance, or `nil` if it's not possible.
    init?(tempo: Int, length: Int, dots: Int) {
        guard
            Self.validTempoRange.contains(tempo),
            Self.validLengthRange.contains(length),
            dots >= 0
        else {
            return nil
        }
        
        self.tempo = tempo
        
        // Sustain is computed from the number of dots, with the first dot representing an
        // additional half-length, and each subsequent dot adding a progressively halved values. For
        // example, one dot makes a rest 0.5 times as long, two dots makes a rest 0.75 times as
        // long, three dots makes a rest 0.875 times as long, and so on.
        let sustain = 2.0 - pow(0.5, Beat(dots))
        
        // Duration of rest is computed based on 4/4 timing.
        self.duration = (4.0 / Beat(length)) * sustain
    }
}


// MARK: - Music Event
extension Rest {
    func samples(sampleRate: Hertz) -> [Float] {
        // Total time is based on tempo. For example a quarter note (one beat at 4/4 timing) at
        // 120 bpm tempo is 0.5 seconds long.
        let totalTime = (60.0 / Beat(tempo)) * duration
        let count = Int((sampleRate * totalTime).rounded())
        return Array(repeating: 0.0, count: count)
    }
}
