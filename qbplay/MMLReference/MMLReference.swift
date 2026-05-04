import Foundation
import SwiftUI

/// An object representing MML documentation.
struct MMLReference: Decodable {
    let command: String
    let description: String
    let options: [MMLReferenceOption]
}


/// An object representing MML command option documentation.
struct MMLReferenceOption: Decodable {
    let token: String
    let description: String
}
