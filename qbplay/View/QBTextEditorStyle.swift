import SwiftUI

/// A modifier that mimics the MS-DOS QBasic text editor.
struct QBTextEditorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .border(.vgaWhite, width: 1)
            .scrollContentBackground(.hidden)
            .background(.vgaBlue)
            .font(.custom("Px437 IBM VGA 9x16", size: 16))
            .foregroundStyle(.vgaWhite)
            .tint(.vgaWhite)
    }
}

extension View where Self == TextEditor {
    /// A modifier that mimics the MS-DOS QBasic text editor.
    func qbasicTextEditorStyle() -> some View {
        modifier(QBTextEditorStyle())
    }
}
