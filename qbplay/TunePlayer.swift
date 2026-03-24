import AVFoundation
import Foundation
import Observation

@Observable
final class TunePlayer {
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    
    // MARK: - Initializers
    init() throws {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Computed Properties
    var isPlaying: Bool { audioPlayerNode.isPlaying }
    
    // MARK: - Methods
    func play(_ events: [TuneEvent]) throws {
        guard !events.isEmpty else { return }
        var samples: [Float] = []
        let format = audioEngine.outputNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        
        let totalSamples = events.reduce(0) { sum, event in
            switch event {
            case .note(let note):
                sum + Int(note.duration * sampleRate)
            case .rest(let rest):
                sum + Int(rest.duration * sampleRate)
            }
        }
        
        samples.reserveCapacity(totalSamples)
        
        for event in events {
            switch event {
            case .note(let note):
                samples.append(contentsOf: note.samples(sampleRate: sampleRate))
            case .rest(let rest):
                samples.append(contentsOf: rest.samples(sampleRate: sampleRate))
            }
        }
        
        guard
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
            let channelData = buffer.floatChannelData
        else {
            throw PlayerError.noAudioData
        }
        
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let channelCount = Int(format.channelCount)
        samples.withUnsafeBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            
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
extension TunePlayer {
    enum PlayerError: Error {
        case noAudioData
    }
}
