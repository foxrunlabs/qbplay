import AVFoundation
import Observation

/// An object that plays audio waveforms.
@Observable
final class AudioPlayer {
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private(set) var isPlaying = false
    
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
    
    // MARK: - Methods
    /// Creates a PCM buffer for audio samples.
    /// - Parameters:
    ///   - samples: Audio samples.
    ///   - format: PCM format.
    /// - Returns: An audio PCM buffer, or `nil` if failed.
    func pcmBuffer(for samples: [Float], format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(samples.count)
        
        guard
            frameCount > 0,
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
            let channelData = buffer.floatChannelData
        else {
            return nil
        }
        
        // Copy the audio waveform to the audio PCM buffer channels.
        buffer.frameLength = frameCount
        samples.withUnsafeBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            
            // Automatically accounts for mono or stereo.
            for channel in 0..<Int(format.channelCount) {
                channelData[channel].update(from: base, count: samples.count)
            }
        }
        
        return buffer
    }
    
    /// Plays audio.
    /// - Parameter samples: An array of audio samples.
    func play(_ samples: [Float]) {
        guard let buffer = pcmBuffer(for: samples, format: format) else { return }
        
        isPlaying = false
        audioPlayerNode.stop()
        
        audioPlayerNode.scheduleBuffer(buffer, at: nil) { [weak self] in
            // Execute on the main thread
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isPlaying = false
            }
        }
        
        audioPlayerNode.play()
        isPlaying = true
    }
    
    /// Stops audio.
    func stop() {
        isPlaying = false
        audioPlayerNode.stop()
    }
}
