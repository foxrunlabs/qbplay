import SwiftUI

/// A button style that mimics the buttons in the bottom toolbar of the MS-DOS QBasic editor.
struct QBButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let foregroundColor: Color = if isEnabled {
            configuration.isPressed ? .vgaCyan : .vgaBrightWhite
        } else {
            .vgaLightGray
        }
        
        configuration.label
            .background(configuration.isPressed ? .vgaBrightWhite : .clear)
            .foregroundStyle(foregroundColor)
            .clipShape(Rectangle())
            .font(.custom("Px437 IBM VGA 9x16", size: 16))
    }
}


extension ButtonStyle where Self == QBButtonStyle {
    /// A button style that mimics the buttons in the bottom toolbar of the MS-DOS QBasic editor.
    static var qbasic: Self { .init() }
}
