import Accelerate
import Foundation

struct Note {
    let pitch: Pitch
    let duration: TimeInterval
    let technique: Technique
    
    // MARK: - Initializer
    init(
        pitch: Pitch,
        tempo: Int,
        length: Int,
        dots: Int?,
        technique: Technique
    ) {
        self.pitch = pitch
        let sustain = dots.map { 2.0 - pow(0.5, TimeInterval($0)) } ?? 1.0
        self.duration = (60.0 / TimeInterval(tempo)) * (4.0 / TimeInterval(length)) * sustain
        self.technique = technique
    }
    
    // MARK: - Methods
    func samples(sampleRate: Hertz) -> [Float] {
        // Compute total samples, note samples, and rest samples based on technique
        let totalCount = Int(sampleRate * duration)
        let noteCount = Int(Double(totalCount) * technique.rawValue)
        let restCount = totalCount - noteCount
        
        // Generate waveform of note, including rest based on technique
        let indices = vDSP.ramp(withInitialValue: Float.zero, increment: 1.0, count: noteCount)
        let phaseIncrement = Float(2.0 * Double.pi * pitch.frequency / sampleRate)
        let phases = vDSP.multiply(phaseIncrement, indices)
        var waveform = vForce.sin(phases)
        
        // Apply ADSR envelope to minimize clicking
        adsrEnvelope(attack: 0.005, release: 0.005, waveform: &waveform, sampleRate: sampleRate)
        
        return waveform + Array(repeating: 0.0, count: restCount)
    }
    
    private func adsrEnvelope(
        attack: TimeInterval,
        release: TimeInterval,
        waveform: inout [Float],
        sampleRate: Hertz
    ) {
        let attackCount = min(Int(sampleRate * attack), waveform.count / 2)
        let releaseCount = min(Int(sampleRate * release), waveform.count / 2)
        
        if attackCount > 0 {
            let attackEnvelope = vDSP.ramp(
                withInitialValue: Float.zero,
                increment: 1.0 / Float(attackCount),
                count: attackCount
            )
            
            vDSP.multiply(attackEnvelope, waveform[..<attackCount], result: &waveform[..<attackCount])
        }
        
        if releaseCount > 0 {
            let releaseEnvelope = vDSP.ramp(
                withInitialValue: 1.0,
                increment: -1.0 / Float(releaseCount),
                count: releaseCount
            )
            
            let start = waveform.count - releaseCount
            vDSP.multiply(
                releaseEnvelope,
                waveform[start...],
                result: &waveform[start...]
            )
        }
    }
}
