import AVFoundation

extension AVAudioPCMBuffer {
    /// Creates a PCM audio buffer from audio samples.
    /// - Parameters:
    ///   - samples: Audio samples.
    ///   - format: The format of the PCM audio the buffer contains.
    /// - Returns: A new AVAudioPCMBuffer, or `nil` if it's not possible.
    static func makeMonoBuffer(from samples: [Float], format: AVAudioFormat) -> AVAudioPCMBuffer? {
        // Automatically fails if samples.count is empty.
        guard
            format.commonFormat == .pcmFormatFloat32,
            !format.isInterleaved,
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(samples.count)
            ),
            let channelData = buffer.floatChannelData
        else {
            return nil
        }
        
        // Copy the audio waveform to the audio PCM buffer channels.
        buffer.frameLength = buffer.frameCapacity
        for channel in 0..<Int(format.channelCount) {
            channelData[channel].update(from: samples, count: samples.count)
        }

        return buffer
    }
}
