import AVFoundation
import Observation

extension ContentView {
    @MainActor
    @Observable
    final class ViewModel {
        var tune: String = "" {
            didSet { validateTune() }
        }
        
        private var musicEvents: [MusicEvent] = []
        private(set) var validationError: Error?
        private let player: AudioPlayer
        
        // MARK: - Initializer
        init(audioPlayer: AudioPlayer) {
            self.player = audioPlayer
        }
        
        // MARK: - Computed Properties
        var isValidMML: Bool { !musicEvents.isEmpty && validationError == nil }
        var isPlaying: Bool { player.isPlaying }
        
        // MARK: - Methods
        /// Validates the MML command string.
        /// - Parameter tune: MML command string.
        private func validateTune() {
            do {
                let commands = try MMLLexer.lex(tune)
                musicEvents = try MMLInterpreter.interpret(commands)
                validationError = nil
            } catch {
                musicEvents = []
                validationError = error
            }
        }
        
        /// Creates audio buffer.
        private func makeBuffer() -> AVAudioPCMBuffer? {
            let samples = Synthesizer.render(musicEvents, sampleRate: player.format.sampleRate)
            return AVAudioPCMBuffer.makeMonoBuffer(from: samples, format: player.format)
        }
        
        /// Plays the current tune.
        func play() {
            guard let buffer = makeBuffer() else { return }
            player.play(buffer)
        }
        
        /// Stops playback.
        func stop() {
            player.stop()
        }
        
        /// Exports the current tune as audio.
        func export(to url: URL) throws {
            guard let buffer = makeBuffer() else { return }
            
            let file = try AVAudioFile(
                forWriting: url,
                settings: buffer.format.settings,
                commonFormat: buffer.format.commonFormat,
                interleaved: buffer.format.isInterleaved
            )
            
            try file.write(from: buffer)
        }
    }
}
