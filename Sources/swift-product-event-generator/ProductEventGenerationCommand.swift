import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

// MARK: - Code Generation

struct ProductEventGenerator {

    func generate(from definitions: [ProductEventDefinition], outputDir: String) throws {
        let objectName = "ProductEvent"
        let fileManager = FileManager.default
        try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        let importDecl = ImportDeclSyntax(path: ImportPathComponentListSyntax {
            ImportPathComponentSyntax(name: .identifier("Foundation"))

        })
            .with(\.trailingTrivia, .newlines(2) + .lineComment("// AUTO-GENERATED - DO NOT EDIT") + .newline)
        var content = importDecl.formatted().description

        // Generate enums for constrained attributes
        for event in definitions {
            guard let attributes = event.attributes else { continue }
            for attr in attributes {
                if let allowed = attr.allow {
                    let enumSyntax = SwiftSyntaxGenerator.generateEnumSyntax(
                        name:  enumTypeName(event: event.name, attribute: attr.name),
                        type: "String",
                        cases: allowed.map { camelCase(for: $0) }
                    )
                    content += enumSyntax.formatted().description
                }
            }
        }

        let productEventSyntax = SwiftSyntaxGenerator.generateStructSyntax(name: objectName, properties: [("name", "String"), ("attributes", "[String: String]?")])

        content += productEventSyntax.formatted().description

        let methods: [(
            name: String,
            params: [(name: String, type: String, description: String)],
            eventName: String,
            attrEntries: [(key: String, isEnum: Bool)]?,
            description: String)] = definitions.map { event in
            let methodName = camelCase(for: event.name)
            let params: [(name: String, type: String, description: String)] = event.attributes?.map { attr in
                let type = attr.allow != nil ? enumTypeName(event: event.name, attribute: attr.name) : "String"
                return (name: attr.name, type: type, description: attr.description)
            } ?? []
            let attrEntries: [(key: String, isEnum: Bool)]? = event.attributes?.map { attr in
                (key: attr.name, isEnum: attr.allow != nil)
            }
            return (name: methodName, params: params, eventName: event.name, attrEntries: attrEntries, description: event.description)
        }

        let extensionDecl = SwiftSyntaxGenerator.generateExtenstionSyntax(
            typeName: objectName,
            methods: methods
        )
        content += extensionDecl.formatted().description

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
