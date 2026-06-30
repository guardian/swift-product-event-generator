import Testing
import Foundation
@testable import swift_product_event_code_generator

struct ProductEventDefinitionTests {

    @Test
    func decodesFullDefinition() async throws {
        let json = """
            {
                        "name": "screen_view",
                        "description": "User viewed a screen",
                        "attributes": [
                            {
                                "name": "screenType",
                                "description": "The screen type",
                                "allow": ["home", "settings"]
                            }
                        ]
                    }
            """.data(using: .utf8)!

        let definition = try JSONDecoder().decode(ProductEventDefinition.self, from: json)
        assert(definition.name == "screen_view")
        assert(definition.attributes?.count == 1)
        assert(definition.attributes?.first?.name == "screenType")
    }

    @Test
    func decodesWithoutAttributes() async throws {
        let json = """
            {
                        "name": "screen_view",
                        "description": "User viewed a screen"
                    }
            """.data(using: .utf8)!

        let definition = try JSONDecoder().decode(ProductEventDefinition.self, from: json)
        assert(definition.name == "screen_view")
        assert(definition.description == "User viewed a screen")
        assert(definition.attributes == nil)
    }

    @Test
    func testDecodesAttributeWithoutAllow() throws {
        let json = """
            {"name": "userId", "description": "The user ID"}
            """.data(using: .utf8)!

        let attr = try JSONDecoder().decode(ProductEventAttribute.self, from: json)

        assert(attr.allow == nil)
        assert(attr.description == "The user ID")
    }

}
