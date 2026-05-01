import AppKit
import AVFoundation
import SwiftUI

struct ContentView: View {
    let player: AudioPlayer
    
    @State private var tuneString = ""
    @FocusState private var isEditorFocused: Bool
    
    @State private var musicEvents: [MusicEvent] = []
    @State private var validationError: Error?
    
    // MARK: - Computed Properties
    private var playButtonLabel: String { player.isPlaying ? "<Cmd+R=Stop>" : "<Cmd+R=Play>" }
    private var isValidMML: Bool { !musicEvents.isEmpty && validationError == nil }
    private var canPlay: Bool { player.isPlaying || isValidMML }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("QBasic Music Player")
                    .font(.custom("Px437 IBM VGA 9x16", size: 16))
                    .foregroundStyle(.vgaBlack)
            }
            .frame(maxWidth: .infinity)
            .background(.vgaWhite)
            
            TextEditor(text: $tuneString)
                .qbasicTextEditorStyle()
                .focused($isEditorFocused)
                .onChange(of: tuneString) {
                    player.stop()
                    validateTune()
                }
            
            HStack {
                Button(playButtonLabel, action: play)
                    .keyboardShortcut("r", modifiers: .command)
                    .disabled(!canPlay)
                
                Button("<Cmd+E=Export>", action: export)
                    .keyboardShortcut("e", modifiers: .command)
                    .disabled(!isValidMML)
                
                Spacer()
            }
            .buttonStyle(.qbasic)
            .padding(4)
        }
        .frame(width: 640, height: 480)
        .background(.vgaCyan)
        .onAppear {
            isEditorFocused = true
            validateTune()
        }
    }
    
    // MARK: - Methods
    /// Validates the MML command string.
    private func validateTune() {
        do {
            let commands = try MMLLexer.lex(tuneString)
            musicEvents = try MMLInterpreter.interpret(commands)
            validationError = nil
        } catch {
            musicEvents = []
            validationError = error
        }
    }
    
    /// Creates a PCM audio buffer from the music events.
    private func makeAudioBuffer() -> AVAudioPCMBuffer? {
        let samples = MusicEventRenderer.render(musicEvents, sampleRate: player.format.sampleRate)
        return AudioBufferRenderer.render(samples, format: player.format)
    }
    
    /// Opens a save panel to export the MML string in WAV format.
    private func export() {
        guard let audioBuffer = makeAudioBuffer() else { return }
        
        let panel = NSSavePanel()
        panel.title = "Export Tune"
        panel.allowedContentTypes = [.wav]
        panel.showsContentTypes = true
        panel.nameFieldStringValue = "music.wav"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            do {
                let file = try AVAudioFile(
                    forWriting: url,
                    settings: audioBuffer.format.settings,
                    commonFormat: audioBuffer.format.commonFormat,
                    interleaved: audioBuffer.format.isInterleaved
                )
                
                try file.write(from: audioBuffer)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Plays music.
    private func play() {
        if player.isPlaying {
            player.stop()
        } else if let audioBuffer = makeAudioBuffer() {
                player.play(audioBuffer)
        }
    }
}


// MARK: - Preview
#Preview {
    let player = try? AudioPlayer(sampleRate: 48_000.0, channels: 1)
    
    if let player {
        ContentView(player: player)
    } else {
        ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
    }
}
