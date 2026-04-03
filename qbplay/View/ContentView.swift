import AVFoundation
import SwiftUI

struct ContentView: View {
    let player: AudioPlayer
    
    @State private var tune: String = ""
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("QBasic Music Player")
                    .font(.custom("Px437 IBM VGA 9x16", size: 16))
                    .foregroundStyle(.vgaBlack)
            }
            .frame(maxWidth: .infinity)
            .background(.vgaLightGray)
            
            TextEditor(text: $tune)
                .qbasicTextEditorStyle()
                .focused($isFocused)
            
            HStack {
                Button("<Play>", action: play)
                Button("<Stop>", action: player.stop)
                Button("<Export>", action: export)
                Spacer()
            }
            .buttonStyle(.qbasic)
            .padding(4)
        }
        .frame(width: 640, height: 480)
        .background(.vgaCyan)
        .onAppear {
            isFocused = true
        }
    }
    
    // MARK: - Methods
    private func export() {}
    
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
