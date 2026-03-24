import SwiftUI

struct ContentView: View {
    let player: TunePlayer
    
    private let lexer = TuneLexer()
    private let interpreter = TuneInterpreter()
    
    @State private var tune: String = ""
    @State private var commands: [MMLCommand] = []
    @State private var events: [TuneEvent] = []
    
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
            commands = try lexer.lex(tune.trimmingCharacters(in: .whitespacesAndNewlines))
            events = try interpreter.interpret(commands)
            try player.play(events)
        } catch {
            commands.removeAll()
            events.removeAll()
        }
    }
}


// MARK: - Preview
#Preview {
    let player = try? TunePlayer()
    
    if let player {
        ContentView(player: player)
    } else {
        ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
    }
}
