import SwiftUI

@main
struct qbplayApp: App {
    private let player = try? AudioPlayer(sampleRate: 48_000.0, channels: 1)
    
    var body: some Scene {
        WindowGroup {
            if let player {
                ContentView(player: player)
            } else {
                ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
            }
        }
        .windowResizability(.contentSize)
    }
}
