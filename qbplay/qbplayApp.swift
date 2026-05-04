import SwiftUI

@main
struct qbplayApp: App {
    private let player = try? AudioPlayer(sampleRate: 48_000.0, channels: 1)
    private let documentation: [MMLReference] = Bundle.main.decode(from: "mml_documentation.json")
    
    var body: some Scene {
        WindowGroup {
            if let player {
                ContentView(player: player)
            } else {
                ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
            }
        }
        .windowResizability(.contentSize)
        
        UtilityWindow("MML Reference", id: "mml-reference") {
            MMLReferenceView(documentation: documentation)
                .frame(minWidth: 320, minHeight: 240)
        }
        .windowResizability(.contentSize)
    }
}
