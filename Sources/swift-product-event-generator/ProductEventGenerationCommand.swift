import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

// MARK: - Code Generation

struct ProductEventGenerator {

    func generate(from definitions: [ProductEventDefinition], outputDir: String) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        var content = "import Foundation\n\n// AUTO-GENERATED - DO NOT EDIT \n\n"

        // Generate enums for constrained attributes
        for event in definitions {
            guard let attributes = event.attributes else { continue }
            for attr in attributes {
                if let allowed = attr.allow {
                    let enumSyntax = SwiftSyntaxGenerator.generateEnumSyntax(name:  enumTypeName(event: event.name, attribute: attr.name), type: "String", cases: allowed)
                    content += enumSyntax.formatted().description
                }
            }
        }

        let productEventSyntax = SwiftSyntaxGenerator.generateStructSyntax(name: "ProductEvent", properties: [("name", "String"), ("attributes", "[String: String]?")])

        content += productEventSyntax.formatted().description

        // Extension with static factory methods
        content += "extension ProductEvent {\n\n"

        for event in definitions {
            let methodName = camelCase(for: event.name)

            // Build parameter list
            let params = event.attributes?.compactMap { attr -> String in
                let type = attr.allow != nil ? enumTypeName(event: event.name, attribute: attr.name) : "String"
                return "\(attr.name): \(type)"
            }.joined(separator: ", ")

            // Build attributes dictionary entries
            let attrEntries = event.attributes?.compactMap { attr -> String in
                let valueExpr = attr.allow != nil ? "\(attr.name).rawValue" : attr.name
                return "            \"\(attr.name)\": \(valueExpr)"
            }.joined(separator: ",\n")

            content += "    /// \(event.name)\n"
            if let parameters = event.attributes {
                content += "    /// - Parameters:\n"
                for attr in parameters {
                    content += "    ///   - \(attr.name): \(attr.description)\n"
                }
            }
            content += "    /// - Returns: A ProductEvent for \(event.name)\n"
            content += "    public static func \(methodName)"
            if let params {
                content += "(\(params)) -> ProductEvent {\n"
            } else {
                content += "() -> ProductEvent {\n"
            }
            content += "        ProductEvent(\n"
            content += "            name: \"\(event.name)\",\n"
            if let attributeParameters = attrEntries  {
                content += "            attributes: [\n"
                content += "\(attributeParameters)\n"
            }
            content += "            ]\n"
            content += "        )\n"
            content += "    }\n\n"
        }

        content += "}\n"

        let filePath = (outputDir as NSString).appendingPathComponent("ProductEvent.swift")
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        print("Generated: \(filePath)")
    }

    private func structName(for name: String) -> String {
        name.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined() + "Event"
    }

    private func camelCase(for name: String) -> String {
        let parts = name.split(separator: "_")
        return String(parts[0]) + parts.dropFirst()
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined()
    }

    private func enumTypeName(event: String, attribute: String) -> String {
        structName(for: event).replacingOccurrences(of: "Event", with: "") + attribute.prefix(1).uppercased() + attribute.dropFirst()
    }
}

// MARK: - Command

@main
struct ProductEventGenerationCommand: ParsableCommand {

    @Option(help: "Path to the JSON definitions")
    public var input: String

    @Option(help: "Path to the generated models directory")
    public var output: String

    func run() throws {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: input)
        let jsonFiles = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }
        guard jsonFiles.isEmpty == false else {
            print("No JSON files found in \(input)")
            return
        }
        var allDefinitions: [ProductEventDefinition] = []
        for file in jsonFiles {
            let data = try Data(contentsOf: file)
            let definitions = try JSONDecoder().decode([ProductEventDefinition].self, from: data)
            allDefinitions.append(contentsOf: definitions)
        }
        try ProductEventGenerator().generate(from: allDefinitions, outputDir: output)
    }
}
