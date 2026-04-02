import SwiftUI

/// A button style that mimics the buttons in the bottom toolbar of the MS-DOS QBasic editor.
struct QBButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.qbBrightWhite : Color.clear)
            .foregroundStyle(configuration.isPressed ? Color.qbCyan : Color.qbBrightWhite)
            .clipShape(Rectangle())
            .font(.custom("Px437 IBM VGA 9x16", size: 16))
    }
}

extension ButtonStyle where Self == QBButtonStyle {
    /// A button style that mimics the buttons in the bottom toolbar of the MS-DOS QBasic editor.
    static var qbasic: Self { Self() }
}
