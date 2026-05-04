import SwiftUI

extension ShapeStyle where Self == Color {
    /// Default VGA black.
    static var vgaBlack: Color { Color(red: 0, green: 0, blue: 0) }

    /// Default VGA blue.
    static var vgaBlue: Color { Color(red: 0, green: 0, blue: 170) }
    
    /// Default VGA green.
    static var vgaGreen: Color { Color(red: 0, green: 170, blue: 0) }
    
    /// Default VGA cyan.
    static var vgaCyan: Color { Color(red: 0, green: 170, blue: 170) }
    
    /// Default VGA red.
    static var vgaRed: Color { Color(red: 170, green: 0, blue: 0) }
    
    /// Default VGA magenta.
    static var vgaMagenta: Color { Color(red: 170, green: 0, blue: 170) }
    
    /// Default VGA brown.
    static var vgaBrown: Color { Color(red: 170, green: 85, blue: 0) }
    
    /// Default VGA white.
    static var vgaWhite: Color { Color(red: 170, green: 170, blue: 170) }
    
    /// Default VGA dark gray.
    static var vgaDarkGray: Color { Color(red: 85, green: 85, blue: 85) }
    
    /// Default VGA bright blue.
    static var vgaBrightBlue: Color { Color(red: 85, green: 85, blue: UInt8.max) }
    
    /// Default VGA bright green.
    static var vgaBrightGreen: Color { Color(red: 85, green: UInt8.max, blue: 85) }
    
    /// Default VGA bright cyan.
    static var vgaBrightCyan: Color { Color(red: 85, green: UInt8.max, blue: UInt8.max) }
    
    /// Default VGA bright red.
    static var vgaBrightRed: Color { Color(red: UInt8.max, green: 85, blue: 85) }
    
    /// Default VGA bright magenta.
    static var vgaBrightMagenta: Color { Color(red: UInt8.max, green: 85, blue: UInt8.max) }
    
    /// Default VGA bright yellow.
    static var vgaBrightYellow: Color { Color(red: UInt8.max, green: UInt8.max, blue: 85) }
    
    /// Default VGA bright white.
    static var vgaBrightWhite: Color { Color(red: UInt8.max, green: UInt8.max, blue: UInt8.max) }
}


// MARK: - Color Extension
fileprivate extension Color {
    /// Creates a constant color from red, green, and blue component values.
    /// - Parameters:
    ///   - red: The amount of red in the color.
    ///   - green: The amount of green in the color.
    ///   - blue: The amount of blue in the color.
    ///   - opacity: An optional degree of opacity, given in the range 0 to 255. A value of 0 means 100% transparency, while a
    ///   value of 255 means 100% opacity. The default is 255.
    init(red: UInt8, green: UInt8, blue: UInt8, opacity: UInt8 = UInt8.max) {
        self.init(
            red: Double(red) / Double(UInt8.max),
            green: Double(green) / Double(UInt8.max),
            blue: Double(blue) / Double(UInt8.max),
            opacity: Double(opacity) / Double(UInt8.max)
        )
    }
}
