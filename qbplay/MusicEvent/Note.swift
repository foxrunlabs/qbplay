import Foundation

/// A representation of a musical note.
struct Note: MusicEvent {
    let pitch: Pitch
    let articulation: Articulation
    let duration: Double
    let absoluteDuration: TimeInterval
    
    private static let validTempoRange = 32...255
    private static let validLengthRange = 1...64
    
    // MARK: - Initializer
    
    /// Creates a note.
    /// - Parameters:
    ///   - pitch: Pitch of the note.
    ///   - tempo: A value in the range of `32...255` representing the number of quarter notes per minute.
    ///   - articulation: The playing technique for the note.
    ///   - length: A value in the range of `1...64` representing the length of the note. `1` represents a whole note, `2` is a
    ///     half note, `4` is a quarter note, and so on.
    ///   - dots: A value representing the number of sustain dots for the note.
    /// - Returns: A new `Note` instance, or `nil` if it's not possible.
    init?(
        pitch: Pitch,
        tempo: Int,
        articulation: Articulation,
        length: Int,
        dots: Int
    ) {
        guard
            Self.validTempoRange.contains(tempo),
            Self.validLengthRange.contains(length),
            dots >= 0
        else {
            return nil
        }
        
        self.pitch = pitch
        self.articulation = articulation
        
        // Sustain is computed from the number of dots, with the first dot representing an
        // additional half-length, and each subsequent dot adding a progressively halved values. For
        // example, one dot makes a note 0.5 times as long, two dots makes a note 0.75 times as
        // long, three dots makes a note 0.875 times as long, and so on.
        let sustain = 2.0 - pow(0.5, Double(dots))
        
        // Duration of the note in beats is computed based on 4/4 timing.
        self.duration = (4.0 / Double(length)) * sustain
        
        // Absolute duration is based on tempo. For example a quarter note (one beat at 4/4 timing)
        // at 120 bpm tempo is 0.5 seconds long.
        self.absoluteDuration = (60.0 / TimeInterval(tempo)) * self.duration
    }
}
