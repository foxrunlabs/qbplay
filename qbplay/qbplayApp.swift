import SwiftUI

@main
struct qbplayApp: App {
    private let player = try? TunePlayer()
    
    var body: some Scene {
        WindowGroup {
            if let player {
                ContentView(player: player)
            } else {
                ContentUnavailableView("Audio Unavailable", systemImage: "speaker.slash")
            }
        }
    }
}
