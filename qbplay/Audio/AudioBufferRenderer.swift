import AVFoundation

/// An object that renders audio samples into a PCM buffer.
struct AudioBufferRenderer {
    /// Creates a PCM buffer for audio samples.
    /// - Parameters:
    ///   - samples: Audio samples.
    ///   - format: The audio format for the PCM buffer.
    /// - Returns: An audio PCM buffer, or `nil` if unable.
    static func render(_ samples: [Float], format: AVAudioFormat) -> AVAudioPCMBuffer? {
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
}
