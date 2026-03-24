import Foundation

struct Rest {
    let duration: TimeInterval
    
    // MARK: - Initializers
    init(tempo: Int, length: Int, dots: Int?) {
        let sustain = dots.map { 2.0 - pow(0.5, TimeInterval($0)) } ?? 1.0
        self.duration = (60.0 / TimeInterval(tempo)) * (4.0 / TimeInterval(length)) * sustain
    }
    
    // MARK: - Methods
    func samples(sampleRate: Hertz) -> [Float] {
        let count = Int(sampleRate * duration)
        return Array(repeating: 0.0, count: count)
    }
}
