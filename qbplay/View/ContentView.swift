import AppKit
import AVFoundation
import SwiftUI

struct ContentView: View {
    let player: AudioPlayer
    
    @State private var tuneString = ""
    @FocusState private var isEditorFocused: Bool
    
    @State private var renderedTune: [Float] = []
    @State private var validationError: Error?
    
    // MARK: - Computed Properties
    private var isValidMML: Bool { !renderedTune.isEmpty && validationError == nil }
    private var playButtonLabel: String { player.isPlaying ? "<Stop>" : "<Play>" }
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
                    .disabled(!canPlay)
                
                Button("<Export>", action: export)
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
            renderedTune = try TuneRenderer.render(tuneString, sampleRate: player.format.sampleRate)
            validationError = nil
        } catch {
            renderedTune = []
            validationError = error
        }
    }
    
    /// Opens a save panel to export the MML string in WAV format.
    private func export() {
        guard let buffer = player.pcmBuffer(for: renderedTune, format: player.format) else { return }
        
        let panel = NSSavePanel()
        panel.title = "Export Music"
        panel.allowedContentTypes = [.wav]
        panel.showsContentTypes = true
        panel.nameFieldStringValue = "music.wav"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
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
    
    /// Plays music.
    private func play() {
        if player.isPlaying {
            player.stop()
        } else {
            player.play(renderedTune)
        }
    }
}


// MARK: - Preview
#Preview {
    let player = try? AudioPlayer()
    
    if let player {
        ContentView(player: player)
    } else {
        ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
    }
}
