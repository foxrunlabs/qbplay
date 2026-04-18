import Accelerate
import Foundation

/// A representation of a musical note.
struct Note: MusicEvent {
    let pitch: Pitch
    let duration: TimeInterval
    
    // MARK: - Initializer
    
    /// Creates a note.
    /// - Parameters:
    ///   - pitch: Pitch of the note.
    ///   - tempo: A value in the range of 32 to 255 representing the number of quarter notes per minute.
    ///   - length: A value in the range of 1 to 64 representing the length of the note. A value of 1 represents a whole note, 2 is a
    ///     half note, 4 is a quarter note, and so on.
    ///   - dots: A value representing the number of sustain dots for the note.
    ///   - articulation: The playing technique for the note.
    init(
        pitch: Pitch,
        tempo: Int,
        length: Int,
        dots: Int,
        articulation: Articulation
    ) {
        self.pitch = pitch
        
        // Sustain is computed from the number of dots, with the first dot representing an
        // additional half-length, and each subsequent dot adding a progressively halved values. For
        // example, one dot makes a note 0.5 times as long, two dots makes a note 0.75 times as
        // long, three dots makes a note 0.875 times as long, and so on.
        let sustain = 2.0 - pow(0.5, TimeInterval(dots))
        
        // Duration of note is computed based on tempo of quarter notes per minute and a length
        // normalized based on 4/4 timing. For example, a whote note represented by a length of 1
        // with a tempo of 120 quarter notes per minute would have a length of 2 seconds.
        self.duration = (60.0 / TimeInterval(tempo)) * (4.0 / TimeInterval(length)) * sustain * articulation.rawValue
    }
    
    // MARK: - Methods
    func samples(sampleRate: Hertz) -> [Float] {
        let count = Int((sampleRate * duration).rounded())
        
        // Generate waveform of note, including rest based on articulation
        let indices = vDSP.ramp(withInitialValue: Float.zero, increment: 1.0, count: count)
        let phaseIncrement = Float(2.0 * Double.pi * pitch.frequency / sampleRate)
        let phases = vDSP.multiply(phaseIncrement, indices)
        var waveform: [Float] = vForce.sin(phases).map { $0 >= 0.0 ? 1.0 : -1.0 }
        
        // Apply ADSR envelope to minimize clicking
        adsrEnvelope(attack: 0.005, release: 0.005, waveform: &waveform, sampleRate: sampleRate)
        
        return waveform
    }
    
    /// Apply an attack, decay, sustain, release envelope to a waveform.
    ///
    /// - Parameters:
    ///   - attack: Attack duration in seconds.
    ///   - release: Release duration in seconds.
    ///   - waveform: The waveform to apply the envelope.
    ///   - sampleRate: Sampling rate in Hertz of the waveform.
    ///
    /// - Note: Decay and sustain not implemented.
    private func adsrEnvelope(
        attack: TimeInterval,
        release: TimeInterval,
        waveform: inout [Float],
        sampleRate: Hertz
    ) {
        // Apply the attack as applicable.
        let attackCount = min(Int((sampleRate * attack).rounded()), waveform.count / 2)
        
        if attackCount > 0 {
            let attackEnvelope = vDSP.ramp(
                withInitialValue: Float.zero,
                increment: 1.0 / Float(attackCount),
                count: attackCount
            )
            
            vDSP.multiply(
                attackEnvelope,
                waveform[..<attackCount],
                result: &waveform[..<attackCount]
            )
        }
        
        // Apply the release as applicable.
        let releaseCount = min(Int((sampleRate * release).rounded()), waveform.count / 2)
        
        if releaseCount > 0 {
            let releaseEnvelope = vDSP.ramp(
                withInitialValue: 1.0,
                increment: -1.0 / Float(releaseCount),
                count: releaseCount
            )
            
            let decayStart = waveform.count - releaseCount
            vDSP.multiply(
                releaseEnvelope,
                waveform[decayStart...],
                result: &waveform[decayStart...]
            )
        }
    }
}
