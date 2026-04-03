import SwiftUI

extension ShapeStyle where Self == Color {
    /// Default VGA black.
    static var vgaBlack: Color { Color(red: 0.0, green: 0.0, blue: 0.0) }

    /// Default VGA blue.
    static var vgaBlue: Color { Color(red: 0.0, green: 0.0, blue: 170.0 / 255.0) }
    
    /// Default VGA bright white.
    static var vgaBrightWhite: Color { Color(red: 1.0, green: 1.0, blue: 1.0) }
    
    /// Default VGA cyan.
    static var vgaCyan: Color { Color(red: 0.0, green: 170.0 / 255.0, blue: 170.0 / 255.0) }
    
    /// Default VGA white.
    static var vgaLightGray: Color {
        Color(red: 170.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0)
    }
}
