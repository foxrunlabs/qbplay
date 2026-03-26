/// Playable music events.
enum MusicEvent {
    /// Play a note.
    /// - Parameters:
    ///     - note: The note to play.
    case note(_ note: Note)
    
    /// Play a rest.
    /// - Parameters:
    ///     - rest: the rest to play
    case rest(_ rest: Rest)
}
