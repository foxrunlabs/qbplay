import AVFoundation
import Foundation
import Observation

@Observable
final class TunePlayer {
    var noteLength = 4
    var technique: Technique = .normal
    var octave = 4
    var tempo = 120
    
    let sampleRate: Hertz
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    
    // MARK: - Initializers
    init(sampleRate: Hertz) throws {
        self.sampleRate = sampleRate
        
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // MARK: - Methods
    func play(_ commands: [MMLCommand]) {
        reset()
        var samples: [Float] = []
        
        for command in commands {
            switch command {
            case .noteLength(let length):
                self.noteLength = length
            case .namedNote(let name, let accidental, let length, let dots):
                do {
                    let pitch = try Pitch(name: name, accidental: accidental, octave: octave)
                    let note = Note(
                        pitch: pitch,
                        tempo: tempo,
                        length: length ?? noteLength,
                        dots: dots,
                        technique: technique
                    )
                    
                    samples.append(contentsOf: note.samples(sampleRate: sampleRate))
                } catch {
                    print("Invalid note: \(error.localizedDescription)")
                }
            case .numberedNote(let number, let dots):
                if number == 0 {
                    let rest = Rest(tempo: tempo, length: noteLength, dots: dots)
                    samples.append(contentsOf: rest.samples(sampleRate: sampleRate))
                } else {
                    do {
                        let pitch = try Pitch(noteNumber: number)
                        let note = Note(
                            pitch: pitch,
                            tempo: tempo,
                            length: noteLength,
                            dots: dots,
                            technique: technique
                        )
                        
                        samples.append(contentsOf: note.samples(sampleRate: sampleRate))
                    } catch {
                        print("Invalid note: \(error.localizedDescription)")
                    }
                }
            case .octave(let octave):
                self.octave = octave
            case .octaveDown:
                self.octave = max(0, octave - 1)
            case .octaveUp:
                self.octave = min(octave + 1, 8)
            case .rest(let length, let dots):
                let rest = Rest(tempo: tempo, length: length, dots: dots)
                samples.append(contentsOf: rest.samples(sampleRate: sampleRate))
            case .technique(let technique):
                self.technique = technique
            case .tempo(let tempo):
                self.tempo = tempo
            }
        }
        
        guard
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)),
            let channelData = buffer.floatChannelData
        else {
            print("Could not initialize format, buffer, and channel data")
            return
        }
        
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let leftChannel = channelData[0]
        let rightChannel = channelData[1]
        
        samples.withUnsafeBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            leftChannel.update(from: base, count: samples.count)
            rightChannel.update(from: base, count: samples.count)
        }
        
        audioPlayerNode.stop()
        audioPlayerNode.scheduleBuffer(buffer, at: nil)
        audioPlayerNode.play()
    }
    
    private func reset() {
        noteLength = 4
        technique = .normal
        octave = 4
        tempo = 120
    }
}
