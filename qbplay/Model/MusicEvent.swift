import Foundation

/// Playable music events.
protocol MusicEvent {
    /// Tempo of the music event in beats per minute.
    var tempo: Int { get }
    
    /// Duration of the music event in beats.
    var duration: Beat { get }
    
    /// Calculate waveform samples representing the music event for a given sampling rate.
    /// - Parameter sampleRate: Sampling rate in Hertz.
    /// - Returns: An array of samples representing the music event.
    func samples(sampleRate: Hertz) -> [Float]
}
