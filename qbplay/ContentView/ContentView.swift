import AppKit
import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var viewModel: ViewModel
    @FocusState private var isEditorFocused: Bool
        
    // MARK: - Initializer
    init(audioPlayer: AudioPlayer) {
        self._viewModel = State(initialValue: .init(audioPlayer: audioPlayer))
    }
    
    // MARK: - Computed Properties
    private var playButtonLabel: String { viewModel.isPlaying ? "<Stop>" : "<Play>" }
    private var isPlayStopEnabled: Bool { viewModel.isValidMML || viewModel.isPlaying }
    private var isExportEnabled: Bool { viewModel.isValidMML }
    
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
            TextEditor(text: $viewModel.tune)
                .qbasicTextEditorStyle()
                .focused($isEditorFocused)
            
            // Bottom bar.
            HStack {
                Button(playButtonLabel) {
                    viewModel.isPlaying ? viewModel.stop() : viewModel.play()
                }
                .buttonStyle(.qbasic)
                .keyboardShortcut("r", modifiers: .command)
                .disabled(!isPlayStopEnabled)
                
                Button("<Export>", action: showSavePanel)
                    .buttonStyle(.qbasic)
                    .keyboardShortcut("e", modifiers: .command)
                    .disabled(!isExportEnabled)
                
                Spacer()
                
                if let error = viewModel.validationError {
                    Text(error.localizedDescription)
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
        }
    }
    
    // MARK: - Methods
    /// Opens a save panel to export the MML string to a WAV file.
    private func showSavePanel() {
        let panel = NSSavePanel()
        panel.title = "Export Tune"
        panel.allowedContentTypes = [.wav]
        panel.showsContentTypes = true
        panel.nameFieldStringValue = "music.wav"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else { return }
            
            do {
                try viewModel.export(to: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


// MARK: - Preview
#Preview("QBPlay") {
    @Previewable @State var player = try? AudioPlayer(
        sampleRate: AppSettings.sampleRate,
        channels: 1
    )
    
    if let player {
        ContentView(audioPlayer: player)
    } else {
        ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
    }
}
