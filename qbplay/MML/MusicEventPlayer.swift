import AVFoundation
import Observation

/// An object that plays sequences of MML music events.
@Observable final class MusicEventPlayer {
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    
    // MARK: - Initializers
    
    /// Creates a MML music event player.
    /// - Throws: This initializer throws an error if the `AVAudioEngine` fails to start.
    init() throws {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Computed Properties
    var isPlaying: Bool { audioPlayerNode.isPlaying }
    
    // MARK: - Methods
    
    /// Plays MML music events.
    /// - Parameter events: An array of MML music events.
    /// - Throws: If there is an error creating the audio PCM buffer and pointer to `Float` channel data, this method throws the
    /// PlayerError.noAudioData error.
    func play(_ events: [MusicEvent]) throws {
        guard !events.isEmpty else { return }
        
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        
        // Calculate the total number of samples required for the audio waveform.
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
        
        guard
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(samples.count)
            ),
            let channelData = buffer.floatChannelData
        else {
            throw PlayerError.noAudioData
        }
        
        // Copy the audio waveform to audio PCM buffer channels.
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let channelCount = Int(format.channelCount)
        samples.withUnsafeBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            
            // Automatically accounts for mono or stereo.
            for channel in 0..<channelCount {
                channelData[channel].update(from: base, count: samples.count)
            }
        }
        
        audioPlayerNode.stop()
        audioPlayerNode.scheduleBuffer(buffer, at: nil)
        audioPlayerNode.play()
    }
}


// MARK: - Player Error
extension MusicEventPlayer {
    /// An error that occurs when playing MML music events.
    enum PlayerError: Error {
        /// An indication that there is no audio PCM buffer or channel data.
        case noAudioData
    }
}
