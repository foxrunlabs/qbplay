import SwiftUI

/// Cycles per second.
typealias Hertz = Double

extension Color {
    /// Default VGA blue.
    static let qbBlue = Color(red: 0.0, green: 0.0, blue: 170.0 / 255.0)
    
    /// Default VGA bright white.
    static let qbBrightWhite = Color(red: 1.0, green: 1.0, blue: 1.0)
    
    /// Default VGA cyan.
    static let qbCyan = Color(red: 0.0, green: 170.0 / 255.0, blue: 170.0 / 255.0)
    
    /// Default VGA white.
    static let qbLightGray = Color(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0)
}
