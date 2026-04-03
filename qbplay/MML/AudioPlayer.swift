import AVFoundation
import Observation

/// An object that plays audio waveforms.
@Observable final class AudioPlayer {
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
    var format: AVAudioFormat { audioEngine.outputNode.outputFormat(forBus: 0) }
    var isPlaying: Bool { audioPlayerNode.isPlaying }
    
    // MARK: - Methods
    
    /// Plays audio.
    /// - Parameter samples: An array of samples.
    /// - Throws: If there is an error creating the audio PCM buffer and pointer to `Float` channel data, this method throws the
    /// PlayerError.noAudioData error.
    func play(_ samples: [Float]) throws {
        guard !samples.isEmpty else { return }
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
    
    /// Stops audio.
    func stop() {
        if audioPlayerNode.isPlaying { audioPlayerNode.stop() }
    }
}


// MARK: - Player Error
extension AudioPlayer {
    /// An error that occurs when playing MML music events.
    enum PlayerError: Error {
        /// An indication that there is no audio data available.
        case noAudioData
    }
}
