import Foundation

/// An object that renders MML command strings to audio samples.
struct AudioSamplesRenderer {
    /// Renders audio from a MML command string.
    /// - Parameters:
    ///   - tune: String representing MML commands.
    ///   - sampleRate: Sampling rate in Hertz.
    /// - Returns: An array of audio samples.
    /// - Throws: This method throws a MMLError if it fails to lex or interpret the MML tune.
    static func render(_ tune: String, sampleRate: Hertz) throws -> [Float] {
        let commands = try MMLLexer.lex(tune.trimmingCharacters(in: .whitespacesAndNewlines))
        let events = try MMLInterpreter.interpret(commands)
        return MusicEventRenderer.render(events, sampleRate: sampleRate)
    }
}
