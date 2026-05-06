import AppKit
import AVFoundation
import SwiftUI

struct ContentView: View {
    @Environment(AudioPlayer.self) private var player
    
    @State private var tune = ""
    @FocusState private var isEditorFocused: Bool
    
    @State private var musicEvents: [MusicEvent] = []
    @State private var validationError: Error?
    
    // MARK: - Computed Properties
    private var playButtonLabel: String { player.isPlaying ? "<Stop>" : "<Play>" }
    private var isValidMML: Bool { !musicEvents.isEmpty && validationError == nil }
    private var canPlayOrStop: Bool { isValidMML || player.isPlaying }
    private var canExport: Bool { isValidMML }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Title bar.
            Text("QBasic Music Player")
                .frame(maxWidth: .infinity)
                .font(.custom("Px437 IBM VGA 9x16", size: 16))
                .foregroundStyle(.vgaBlack)
                .background(.vgaWhite)
            
            // Editor.
            TextEditor(text: $tune)
                .qbasicTextEditorStyle()
                .focused($isEditorFocused)
                .onChange(of: tune) {
                    player.stop()
                    validateTune()
                }
            
            // Bottom bar.
            HStack {
                Button(playButtonLabel) {
                    player.isPlaying ? stop() : play()
                }
                .buttonStyle(.qbasic)
                .keyboardShortcut("r", modifiers: .command)
                .disabled(!canPlayOrStop)
                
                Button("<Export>", action: export)
                    .buttonStyle(.qbasic)
                    .keyboardShortcut("e", modifiers: .command)
                    .disabled(!canExport)
                
                Spacer()
                
                if let validationError {
                    Text(validationError.localizedDescription)
                        .font(.custom("Px437 IBM VGA 9x16", size: 16))
                        .foregroundStyle(.vgaBrightYellow)
                }
            }
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
    
    /// Play music events.
    private func play() {
        guard let buffer = makeBuffer() else { return }
        player.play(buffer)
    }
    
    /// Stop music events.
    private func stop() {
        player.stop()
    }
    
    /// Opens a save panel to export the MML string in WAV format.
    private func export() {
        guard let buffer = makeBuffer() else { return }
        
        let panel = NSSavePanel()
        panel.title = "Export Tune"
        panel.allowedContentTypes = [.wav]
        panel.showsContentTypes = true
        panel.nameFieldStringValue = "music.wav"
        
        panel.begin { response in
            guard
                response == .OK,
                let url = panel.url
            else {
                return
            }
            
            do {
                let file = try AVAudioFile(
                    forWriting: url,
                    settings: buffer.format.settings,
                    commonFormat: buffer.format.commonFormat,
                    interleaved: buffer.format.isInterleaved
                )
                
                try file.write(from: buffer)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


// MARK: - Preview
#Preview("QBPlay") {
    @Previewable @State var player = try? AudioPlayer(sampleRate: 48_000.0, channels: 1)
    
    if let player {
        ContentView()
            .environment(player)
    } else {
        ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
    }
}
