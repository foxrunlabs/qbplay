import Foundation

/// A representation of a rest.
struct Rest: MusicEvent {
    let duration: TimeInterval
    
    // MARK: - Initializers
    
    /// Creates a rest.
    /// - Parameters:
    ///   - tempo: A value in the range of 32 to 255 representing the number of quarter notes per minute.
    ///   - length: A value in the range of 1 to 64 representing the length of the rest.
    ///   - dots: A value representing the number of sustain dots for the rest.
    init(tempo: Int, length: Int, dots: Int) {
        // Sustain is computed from the number of dots, with the first dot representing an
        // additional half-length, and each subsequent dot adding a progressively halved values. For
        // example, one dot makes a rest 0.5 times as long, two dots makes a rest 0.75 times as
        // long, three dots makes a rest 0.875 times as long, and so on.
        let sustain = 2.0 - pow(0.5, TimeInterval(dots))
        
        // Duration of rest is computed based on tempo of quarter notes per minute and a length
        // normalized based on 4/4 timing. For example, a whote rest represented by a length of 1
        // with a tempo of 120 quarter notes per minute would have a length of 2 seconds.
        self.duration = (60.0 / TimeInterval(tempo)) * (4.0 / TimeInterval(length)) * sustain
    }
    
    // MARK: - Methods
    func samples(sampleRate: Hertz) -> [Float] {
        let count = Int((sampleRate * duration).rounded())
        return Array(repeating: 0.0, count: count)
    }
}
