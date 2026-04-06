/// An object that renders audio waveforms from music events.
struct AudioRenderer {
    /// Renders an audio waveform..
    /// - Parameters:
    ///     - events: An array of MML music events.
    ///     - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array for floats representing the audio waveform.
    static func render(_ events: [MusicEvent], sampleRate: Hertz) -> [Float] {
        // Calculate the total number of samples required.
        let totalSamples = events.reduce(into: 0) { sum, event in
            sum += Int((event.duration * sampleRate).rounded())
        }
        
        var samples: [Float] = []
        samples.reserveCapacity(totalSamples)
        
        // Generate the audio waveform.
        for event in events {
            samples.append(contentsOf: event.samples(sampleRate: sampleRate))
        }
        
        return samples
    }
}
