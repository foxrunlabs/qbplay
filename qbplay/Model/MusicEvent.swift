import Foundation

/// Playable music events.
protocol MusicEvent {
    /// Duration of the music event in seconds.
    var duration: TimeInterval { get }
    
    /// Calculate waveform samples representing the music event for a given sampling rate.
    /// - Parameter sampleRate: Sampling rate in Hertz.
    /// - Returns: An array of samples representing the music event.
    func samples(sampleRate: Hertz) -> [Float]
}
