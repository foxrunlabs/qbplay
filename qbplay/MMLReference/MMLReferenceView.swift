import SwiftUI

struct MMLReferenceView: View {
    let documentation: [MMLReference]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("MML Syntax")
                    .font(.largeTitle.bold())
                
                Text("Commands are not case sensitive.")
                
                ForEach(documentation, id: \.command) { reference in
                    MMLSyntaxView(reference: reference)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .padding()
    }
}


// MARK: - MML Syntax View
fileprivate struct MMLSyntaxView: View {
    let reference: MMLReference
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(LocalizedStringKey(reference.command))
                .monospaced().bold()
                .foregroundStyle(.vgaBrightWhite)
            
            Text(LocalizedStringKey(reference.description))
            
            if !reference.options.isEmpty {
                Grid(alignment: .topLeading) {
                    ForEach(reference.options, id: \.token) { option in
                        GridRow {
                            Text(LocalizedStringKey(option.token))
                                .frame(minWidth: 50, alignment: .leading)
                            
                            Text(LocalizedStringKey(option.description))
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.leading, 16)
            }
        }
    }
}


// MARK: - Preview
#Preview("MML Reference") {
    let documentation: [MMLReference] = Bundle.main.decode(from: "mml_documentation.json")
    MMLReferenceView(documentation: documentation)
}
