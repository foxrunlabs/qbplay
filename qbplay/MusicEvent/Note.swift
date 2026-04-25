import Accelerate
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
    
    // MARK: - Methods
    
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


// MARK: - Music Event
extension Note {
    func samples(sampleRate: Hertz) -> [Float] {
        // Calculate count of total samples, audible note samples, and rest samples
        let totalCount = Int((sampleRate * absoluteDuration).rounded())
        let noteCount = Int((Double(totalCount) * articulation.rawValue).rounded())
                
        // Generate sine wave of note
        let indices = vDSP.ramp(withInitialValue: Float.zero, increment: 1.0, count: noteCount)
        let phaseIncrement = Float(2.0 * Double.pi * pitch.frequency / sampleRate)
        var noteSamples = vDSP.multiply(phaseIncrement, indices)
        vForce.sin(noteSamples, result: &noteSamples)
        
        // Shape from sine wave to closer to a square wave and adjust amplitude
        let drive: Float = 7.0
        let amplitude: Float = 0.20
        vDSP.multiply(drive, noteSamples, result: &noteSamples)
        vForce.tanh(noteSamples, result: &noteSamples)
        vDSP.multiply(amplitude, noteSamples, result: &noteSamples)
        
        // Apply ADSR envelope to minimize clicking
        adsrEnvelope(attack: 0.001, release: 0.0015, waveform: &noteSamples, sampleRate: sampleRate)
        
        // Copy the note samples to the waveform, accounting for articulation
        var waveform = [Float](repeating: 0.0, count: totalCount)
        waveform.replaceSubrange(0..<noteSamples.count, with: noteSamples)
        
        return waveform
    }
}
