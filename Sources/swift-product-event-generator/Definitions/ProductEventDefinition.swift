import Foundation
// MARK: - Input Models

struct ProductEventAttribute: Decodable {
    let name: String
    let description: String
    let allow: [String]?
}

struct ProductEventDefinition: Decodable {
    let name: String
    let description: String
    let attributes: [ProductEventAttribute]?
}
