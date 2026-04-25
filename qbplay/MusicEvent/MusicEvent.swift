import Foundation

/// Playable music events.
protocol MusicEvent {   
    /// Duration of the music event in beats.
    var duration: Double { get }
    
    /// Duration of the music event in seconds.
    var absoluteDuration: TimeInterval { get }
}
