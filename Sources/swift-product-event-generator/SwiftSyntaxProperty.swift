import SwiftSyntax
import SwiftSyntaxBuilder

public enum SwiftSyntaxGenerator {
    static func generateStructSyntax(name: String, properties: [(String, String)]) -> DeclSyntax {
        let structDecl = StructDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: TokenSyntax(stringLiteral: name)
        ) {
            for (propertyName, propertyType) in properties {
                VariableDeclSyntax(modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.public))
                }, bindingSpecifier: .keyword(.let)) {
                    PatternBindingSyntax(pattern: IdentifierPatternSyntax(identifier: .identifier(propertyName)),
                                         typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier(propertyType)))
                    )
                }
            }
        }
            .with(\.leadingTrivia, .newlines(1)) // Adds a newline before the
            .with(\.trailingTrivia, .newlines(1)) // Adds a newline after the
        return DeclSyntax(structDecl)
    }

    static func generateEnumSyntax(name: String, type: String? = nil, cases: [String]) -> DeclSyntax {
        var inheritanceClause: InheritanceClauseSyntax?
        if let type {
            inheritanceClause = InheritanceClauseSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(type)))
            }
        }

        let enumDecl = EnumDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: .keyword(.public))
            },
            name: TokenSyntax(stringLiteral: name),
            inheritanceClause: inheritanceClause) {
                for caseName in cases {
                    EnumCaseDeclSyntax(elements: EnumCaseElementListSyntax {
                        EnumCaseElementSyntax(name: safeCaseIdentifier(caseName))
                    }
                    )
                }
            }
            .with(\.leadingTrivia, .newlines(1)) // Adds a newline before the
            .with(\.trailingTrivia, .newlines(1)) // Adds a newline after the
        return DeclSyntax(enumDecl)
    }
    
    private static func safeCaseIdentifier(_ name: String) -> TokenSyntax {
        if name == "true" || name == "false" {
            return .identifier("`\(name)`")
        } else {
            return .identifier(name)
        }
    }
}

//public struct SwiftSyntaxProperty {
//    let name: String
//    let type: String
//    let isOptional: Bool
//    let isArray: Bool
//
//    public init(name: String, type: String, isOptional: Bool = false, isArray: Bool = false) {
//        self.name = name
//        self.type = type
//        self.isOptional = isOptional
//        self.isArray = isArray
//    }
//
//    public static func optional(_ name: String, type: String) -> SwiftSyntaxProperty {
//        return SwiftSyntaxProperty(name: name, type: type, isOptional: true, isArray: <#T##Bool#>)
//    }
//
//    public static func optionalArray(_ name: String, type: String) -> SwiftSyntaxProperty {
//        return SwiftSyntaxProperty(name: name, type: type, isOptional: true, isArray: true)
//    }
//}
