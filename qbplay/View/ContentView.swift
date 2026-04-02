import AVFoundation
import SwiftUI

struct ContentView: View {
    @Bindable var player: AudioPlayer
    
    @State private var tune: String = ""
    
    // MARK: - Body
    var body: some View {
        VStack {
            TextField("Tune", text: $tune)
            HStack {
                Spacer()
                Button("Play", action: play)
            }
        }
        .padding()
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
