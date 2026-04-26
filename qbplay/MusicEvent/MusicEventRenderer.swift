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
        
        var phase: Float = 0.0
        for event in events {
            output.append(contentsOf: samples(for: event, phase: &phase, sampleRate: sampleRate))
        }
        
        return output
    }
    
    /// Calculate waveform samples representing the music event for a given sampling rate.
    /// - Parameters:
    ///    - event: Music event.
    ///    - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array of samples representing the music event.
    private static func samples(for event: MusicEvent, phase: inout Float, sampleRate: Hertz) -> [Float] {
        let totalCount = Int((sampleRate * event.absoluteDuration).rounded())
        
        // Rest is easy. Reset the phase accumulator and return an array of zeroes.
        if event is Rest {
            phase = 0.0
            return [Float](repeating: 0.0, count: totalCount)
        }
        
        // If can't cast to Note, then something is wrong.
        guard let note = event as? Note else { return [] }
        
        // The audible part of the note, depending on articulation.
        let noteCount = Int((Double(totalCount) * note.articulation.rawValue).rounded())
                
        // Generate sine wave of note
        let phaseIncrement = Float(2.0 * Double.pi * note.pitch.frequency / sampleRate)
        var noteSamples = vDSP.ramp(
            withInitialValue: phase,
            increment: phaseIncrement,
            count: noteCount
        )
        
        vForce.sin(noteSamples, result: &noteSamples)
        
        // Adjust the phase accumulator and bound to 0...2*pi if legato.
        if note.articulation == .legato {
            phase += Float(noteCount) * phaseIncrement
            phase.formTruncatingRemainder(dividingBy: 2.0 * Float.pi)
        } else {
            phase = 0.0
        }
        
        // Shape from sine wave to closer to a square wave and adjust amplitude.
        // noteSamples = amplitude * tanh(drive * sin)
        let drive: Float = 7.0
        let amplitude: Float = 0.20
        vDSP.multiply(drive, noteSamples, result: &noteSamples)
        vForce.tanh(noteSamples, result: &noteSamples)
        vDSP.multiply(amplitude, noteSamples, result: &noteSamples)
        
        // Apply ADSR envelope to minimize clicking
        let attack: TimeInterval
        let release: TimeInterval
        
        if note.articulation == .legato {
            attack = 0.0
            release = 0.0
        } else {
            attack = 0.001
            release = 0.0015
        }
        
        attackReleaseEnvelope(
            attack: attack,
            release: release,
            waveform: &noteSamples,
            sampleRate: sampleRate
        )
        
        // Copy the note samples to the waveform
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
                withInitialValue: 0.0,
                increment: 1.0 / Float(attackCount - 1),
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
                increment: -1.0 / Float(releaseCount - 1),
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
