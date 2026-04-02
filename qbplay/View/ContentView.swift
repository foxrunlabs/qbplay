import AVFoundation
import SwiftUI

struct ContentView: View {
    @Bindable var player: AudioPlayer
    
    @State private var tune: String = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    var body: some View {
        VStack {
            TextEditor(text: $tune)
                .qbasicTextEditorStyle()
                .focused($isFocused)
            
            HStack {
                Button("<Play>", action: play)
                    .buttonStyle(.qbasic)
                    
                Spacer()
            }
            .padding([.horizontal, .bottom], 4)
        }
        .background(Color.qbCyan)
        .onAppear {
            isFocused = true
        }
    }
    
    // MARK: - Methods
    private func play() {
        do {
            let commands = try MMLLexer.lex(tune.trimmingCharacters(in: .whitespacesAndNewlines))
            let events = try MMLInterpreter.interpret(commands)
            let samples = AudioRenderer.render(events, sampleRate: player.format.sampleRate)
            try player.play(samples)
        } catch {
            
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
