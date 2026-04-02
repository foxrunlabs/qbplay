/// An object that renders audio waveforms from music events.
struct AudioRenderer {
    /// Renders an audio waveform..
    /// - Parameters:
    ///     - events: An array of MML music events.
    ///     - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array for floats representing the audio waveform.
    static func render(_ events: [MusicEvent], sampleRate: Hertz) -> [Float] {
        guard !events.isEmpty else { return [] }
        
        // Calculate the total number of samples required.
        let totalSamples = events.reduce(0) { sum, event in
            switch event {
            case .note(let note):
                sum + Int(note.duration * sampleRate)
            case .rest(let rest):
                sum + Int(rest.duration * sampleRate)
            }
        }
        
        var samples: [Float] = []
        samples.reserveCapacity(totalSamples)
        
        // Generate the audio waveform.
        for event in events {
            switch event {
            case .note(let note):
                samples.append(contentsOf: note.samples(sampleRate: sampleRate))
            case .rest(let rest):
                samples.append(contentsOf: rest.samples(sampleRate: sampleRate))
            }
        }
        
        return samples
    }
}
