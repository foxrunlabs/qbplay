import Accelerate
import Foundation

/// An object that renders audio waveforms from music events.
struct MusicEventRenderer {
    /// Renders audio from music events.
    /// - Parameters:
    ///    - events: An array of music events.
    ///    - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array for floats representing the audio waveform.
    static func render(_ events: [MusicEvent], sampleRate: Hertz) -> [Float] {
        var output: [Float] = []
        output.reserveCapacity(
            events.reduce(0) { $0 + Int(($1.absoluteDuration * sampleRate).rounded()) }
        )
        
        for event in events {
            output.append(contentsOf: samples(for: event, sampleRate: sampleRate) )
        }
        
        return output
    }
    
    /// Calculate waveform samples representing the music event for a given sampling rate.
    /// - Parameters:
    ///    - event: Music event.
    ///    - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array of samples representing the music event.
    private static func samples(for event: MusicEvent, sampleRate: Hertz) -> [Float] {
        let totalCount = Int((sampleRate * event.absoluteDuration).rounded())
        
        if event is Rest { return [Float](repeating: 0.0, count: totalCount) }
        guard let note = event as? Note else { return [] }
        
        let noteCount = Int((Double(totalCount) * note.articulation.rawValue).rounded())
                
        // Generate sine wave of note
        let phaseIncrement = Float(2.0 * Double.pi * note.pitch.frequency / sampleRate)
        var noteSamples = vDSP.ramp(withInitialValue: Float.zero, increment: 1.0, count: noteCount)
        vDSP.multiply(phaseIncrement, noteSamples, result: &noteSamples)
        vForce.sin(noteSamples, result: &noteSamples)
        
        // Shape from sine wave to closer to a square wave and adjust amplitude
        let drive: Float = 7.0
        let amplitude: Float = 0.20
        vDSP.multiply(drive, noteSamples, result: &noteSamples)
        vForce.tanh(noteSamples, result: &noteSamples)
        vDSP.multiply(amplitude, noteSamples, result: &noteSamples)
        
        // Apply ADSR envelope to minimize clicking
        attackReleaseEnvelope(
            attack: 0.001,
            release: 0.0015,
            waveform: &noteSamples,
            sampleRate: sampleRate
        )
        
        // Copy the note samples to the waveform, accounting for articulation
        var waveform = [Float](repeating: 0.0, count: totalCount)
        waveform.replaceSubrange(0..<noteSamples.count, with: noteSamples)
        
        return waveform
        
    }
    
    /// Applies a simple attack/release envelope to a waveform.
    /// - Parameters:
    ///   - attack: Attack duration in seconds.
    ///   - release: Release duration in seconds.
    ///   - waveform: The waveform to apply the envelope.
    ///   - sampleRate: Sampling rate in Hertz of the waveform.
    private static func attackReleaseEnvelope(
        attack: TimeInterval,
        release: TimeInterval,
        waveform: inout [Float],
        sampleRate: Hertz
    ) {
        // Apply the attack as applicable.
        let attackCount = min(Int((sampleRate * attack).rounded()), waveform.count / 2)
        
        if attackCount > 1 {
            let attackEnvelope = vDSP.ramp(
                withInitialValue: .zero,
                increment: 1.0 / Float(max(attackCount - 1, 1)),
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
        
        if releaseCount > 1 {
            let releaseEnvelope = vDSP.ramp(
                withInitialValue: 1.0,
                increment: -1.0 / Float(max(releaseCount - 1, 1)),
                count: releaseCount
            )
            
            let releaseStart = waveform.count - releaseCount
            vDSP.multiply(
                releaseEnvelope,
                waveform[releaseStart...],
                result: &waveform[releaseStart...]
            )
        }
    }
}
