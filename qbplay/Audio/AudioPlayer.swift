import AVFoundation
import Observation

/// An object that plays audio PCM buffers.
@Observable
final class AudioPlayer {
    private(set) var format: AVAudioFormat
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private(set) var isPlaying = false
    
    // MARK: - Initializers
    /// Creates an audio player.
    /// - Throws: This initializer throws an error if the audio engine fails to start.
    init(sampleRate: Hertz, channels: Int) throws {
        guard
            sampleRate > 0,
            let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: sampleRate,
                channels: AVAudioChannelCount(channels),
                interleaved: false
            )
        else {
            throw AudioPlayerError.invalidFormat
        }
        
        self.format = format
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: format)
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Methods
    /// Plays audio.
    /// - Parameter buffer: An audio PCM buffer.
    func play(_ buffer: AVAudioPCMBuffer) {
        guard buffer.format == format else { return }
        
        audioPlayerNode.stop()
        isPlaying = false
        
        audioPlayerNode.scheduleBuffer(
            buffer,
            completionCallbackType: .dataConsumed
        ) { [weak self] _ in
            // Execute on the main thread
            Task { @MainActor [weak self] in
                self?.isPlaying = false
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


// MARK: - Audio Player Error
enum AudioPlayerError: LocalizedError {
    /// An indication that there is an invalid format.
    case invalidFormat
    
    // MARK: - Localized Error
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            "Invalid audio format."
        }
    }
}
