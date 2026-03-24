import SwiftUI

struct ContentView: View {
    @Environment(TuneLexer.self) private var lexer
    @Environment(TunePlayer.self) private var player
    @State private var tune: String = ""
    @State private var commands: [MMLCommand] = []
    @State private var output: String = ""
    
    // MARK: - Body
    var body: some View {
        VStack {
            TextField("Tune", text: $tune)
            HStack {
                Spacer()
                Button("Play", action: play)
            }
            
            GroupBox("Output") {
                Text(output)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .padding()
    }
    
    // MARK: - Methods
    private func play() {
        do {
            commands = try lexer.lex(tune: tune.trimmingCharacters(in: .whitespacesAndNewlines))
            player.play(commands)
            output = commands.map { String(describing: $0) }.joined(separator: "\n")
        } catch {
            commands.removeAll()
            output = error.localizedDescription
        }
    }
}


// MARK: - Preview
#Preview {
    ContentView()
        .environment(TuneLexer())
        .environment(TunePlayer(sampleRate: 48_000.0))
}
