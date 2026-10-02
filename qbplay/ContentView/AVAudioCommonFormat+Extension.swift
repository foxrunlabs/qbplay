import AVFoundation

extension AVAudioCommonFormat: @retroactive CustomStringConvertible, @retroactive CaseIterable, @retroactive Identifiable {
    public static let allCases: [AVAudioCommonFormat] = [
        .pcmFormatInt16,
        .pcmFormatInt32,
        .pcmFormatFloat32,
        .pcmFormatFloat64
    ]
    
    public var description: String {
        switch self {
        case .pcmFormatInt16:
            "Signed 16-bit PCM"
        case .pcmFormatInt32:
            "Signed 32-bit PCM"
        case .pcmFormatFloat32:
            "32-bit Float"
        case .pcmFormatFloat64:
            "64-bit Float"
        default:
            "Other"
        }
    }
    
    public var id: Self { self }
}
