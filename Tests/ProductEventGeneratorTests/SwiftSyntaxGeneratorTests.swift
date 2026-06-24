import Testing
@testable import swift_product_event_generator

struct SwiftSyntaxGeneratorTests {

    @Test
    func generateEnumCases() async throws {
        let result = SwiftSyntaxGenerator.generateEnumSyntax(
            name: "ScreenType",
            type: "String",
            cases: ["home", "settings"]
        )
        let output = result.formatted().description

        assert(output.contains("public enum ScreenType: String"))
        assert(output.contains("case home"))
        assert(output.contains("case settings"))
    }

    @Test
    func generateStructContainsProperties() {
        let result = SwiftSyntaxGenerator.generateStructSyntax(
            name: "ProductEvent",
            properties: [("name", "String"), ("attributes", "[String: String]?")]
        )
        let output = result.formatted().description

        assert(output.contains("public struct ProductEvent"))
        assert(output.contains("public let name: String"))
        assert(output.contains("public let attributes: [String: String]?"))
    }

    @Test
        func generateExtensionWithDocComments() {
            let methods: [(
                name: String,
                params: [(name: String, type: String, description: String)],
                eventName: String,
                attrEntries: [(key: String, isEnum: Bool)]?,
                description: String
            )] = [
                (
                    name: "screenView",
                    params: [("screenType", "ScreenType", "The screen type")],
                    eventName: "screen_view",
                    attrEntries: [("screenType", true)],
                    description: "Tracks screen views"
                )
            ]

            let result = SwiftSyntaxGenerator.generateExtenstionSyntax(
                typeName: "ProductEvent",
                methods: methods
            )
            let output = result.formatted().description

            assert(output.contains("extension ProductEvent"))
            assert(output.contains("public static func screenView"))
            assert(output.contains("/// Tracks screen views"))
            assert(output.contains("/// - Parameters:"))
            assert(output.contains("///   - screenType: The screen type"))
            assert(output.contains("\"screen_view\""))
        }

    @Test
    func generateExtensionWithNoAttributes() {
        let methods: [(
            name: String,
            params: [(name: String, type: String, description: String)],
            eventName: String,
            attrEntries: [(key: String, isEnum: Bool)]?,
            description: String
        )] = [
            (name: "appOpen", params: [], eventName: "app_open", attrEntries: nil, description: "User has opened the app")
        ]

        let result = SwiftSyntaxGenerator.generateExtenstionSyntax(
            typeName: "ProductEvent",
            methods: methods
        )
        let output = result.formatted().description

        assert(output.contains("public static func appOpen"))
        assert(output.contains("User has opened the app"))
        assert(output.contains("attributes") == false)
    }

    @Test
    func enumHandlesBooleanCaseNames() {
        let result = SwiftSyntaxGenerator.generateEnumSyntax(
            name: "Flag",
            type: "String",
            cases: ["true", "false", "maybe"]
        )
        let output = result.formatted().description

        assert(output.contains("`true`") || output.contains("case `true`"))
        assert(output.contains("`false`") || output.contains("case `false`"))
        assert(output.contains("case maybe"))
    }

}
