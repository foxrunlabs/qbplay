import SwiftUI

@main
struct qbplayApp: App {
    let lexer = TuneLexer()
    let player = TunePlayer(sampleRate: 48_000.0)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(lexer)
        .environment(player)
    }
}
