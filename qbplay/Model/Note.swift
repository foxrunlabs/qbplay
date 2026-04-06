import Accelerate
import Foundation

/// A representation of a musical note.
struct Note: MusicEvent {
    let pitch: Pitch
    let duration: TimeInterval
    let articulation: Articulation
    
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
        self.duration = (60.0 / TimeInterval(tempo)) * (4.0 / TimeInterval(length)) * sustain
        self.articulation = articulation
    }
    
    // MARK: - Methods
    
    func samples(sampleRate: Hertz) -> [Float] {
        // Compute total samples, note samples, and rest samples based on articulation
        let totalCount = Int(sampleRate * duration)
        let noteCount = Int(Double(totalCount) * articulation.rawValue)
        let restCount = totalCount - noteCount
        
        // Generate waveform of note, including rest based on articulation
        let indices = vDSP.ramp(withInitialValue: Float.zero, increment: 1.0, count: noteCount)
        let phaseIncrement = Float(2.0 * Double.pi * pitch.frequency / sampleRate)
        let phases = vDSP.multiply(phaseIncrement, indices)
        var waveform = vForce.sin(phases)
        
        // Apply ADSR envelope to minimize clicking
        adsrEnvelope(attack: 0.005, release: 0.005, waveform: &waveform, sampleRate: sampleRate)
        
        return waveform + Array(repeating: 0.0, count: restCount)
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
        // Calculate number of samples for attack and sustain.
        let attackCount = min(Int(sampleRate * attack), waveform.count / 2)
        let releaseCount = min(Int(sampleRate * release), waveform.count / 2)
        
        // Apply the attack as applicable.
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
        
        // Apply the decay as applicable.
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
