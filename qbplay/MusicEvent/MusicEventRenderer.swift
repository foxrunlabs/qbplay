/// An object that renders audio waveforms from music events.
struct MusicEventRenderer {
    /// Renders audio from music events.
    /// - Parameters:
    ///    - events: An array of music events.
    ///    - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array for floats representing the audio waveform.
    static func render(_ events: [MusicEvent], sampleRate: Hertz) -> [Float] {
        events.flatMap { $0.samples(sampleRate: sampleRate) }
    }
}
