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

            InitializerDeclSyntax(
                modifiers: DeclModifierListSyntax {
                    DeclModifierSyntax(name: .keyword(.fileprivate))
                },
                signature: FunctionSignatureSyntax(
                    parameterClause: FunctionParameterClauseSyntax {
                        for (i, (propertyName, propertyType)) in properties.enumerated() {
                            FunctionParameterSyntax(
                                firstName: .identifier(propertyName),
                                type: IdentifierTypeSyntax(name: .identifier(propertyType)),
                                defaultValue: propertyName == "attributes"
                                    ? InitializerClauseSyntax(value: NilLiteralExprSyntax())
                                    : nil,
                                trailingComma: i < properties.count - 1 ? .commaToken() : nil
                            )
                        }
                    }
                )
            ) {
                for (propertyName, _) in properties {
                    InfixOperatorExprSyntax(
                        leftOperand: MemberAccessExprSyntax(
                            base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                            name: .identifier(propertyName)
                        ),
                        operator: AssignmentExprSyntax(),
                        rightOperand: DeclReferenceExprSyntax(baseName: .identifier(propertyName))
                    )
                }
            }
            .with(\.leadingTrivia, .newlines(2))
        }
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

    static func generateExtenstionSyntax(
        typeName: String,
        methods: [(
            name: String,
            params: [(
                name: String,
                type: String,
                description: String
            )],
            eventName: String,
            attrEntries: [(
                key: String,
                isEnum: Bool
            )]?,
            description: String
        )]
    ) -> DeclSyntax {
        let extensionDecl = ExtensionDeclSyntax(extendedType:
                                                    IdentifierTypeSyntax(name: .identifier(typeName))
        ) {
            for method in methods {
                let hasAttributes = method.attrEntries != nil
                let docTrivia = buildMethodDocTrivia(description: method.description, params: method.params)
                FunctionDeclSyntax(
                    modifiers: DeclModifierListSyntax {
                        DeclModifierSyntax(name: .keyword(.public))
                        DeclModifierSyntax(name: .keyword(.static))
                    },
                    name: .identifier(method.name),
                    signature: FunctionSignatureSyntax(parameterClause: FunctionParameterClauseSyntax {
                        for (i, param) in method.params.enumerated() {
                            FunctionParameterSyntax(
                                firstName: .identifier(param.name),
                                type: IdentifierTypeSyntax(name: .identifier(param.type)),
                                trailingComma: i < method.params.count - 1 ? .commaToken() : nil
                            )
                            .with(\.leadingTrivia, .newline)
                        }
                    }
                        .with(\.rightParen, .rightParenToken(leadingTrivia: method.params.isEmpty ? Trivia() : .newline)),
                                                       returnClause:
                                                        ReturnClauseSyntax(
                                                            type: IdentifierTypeSyntax(name: .identifier(typeName))
                                                        )
                                                      )
                ) {
                    FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier(typeName)),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                label: .identifier("name"),
                                colon: .colonToken(),
                                expression: StringLiteralExprSyntax(content: method.eventName),
                                trailingComma: hasAttributes ? .commaToken() : nil
                            )
                            .with(\.leadingTrivia, .newline)
                            if let attrEntries = method.attrEntries {
                                LabeledExprSyntax(
                                    label: .identifier("attributes"),
                                    colon: .colonToken(),
                                    expression: DictionaryExprSyntax {
                                        for (i, entry) in attrEntries.enumerated() {
                                            DictionaryElementSyntax(
                                                key: StringLiteralExprSyntax(content: entry.key),
                                                value: entry.isEnum ? ExprSyntax(
                                                    MemberAccessExprSyntax(
                                                        base: DeclReferenceExprSyntax(baseName: .identifier(entry.key)),
                                                        name: .identifier("rawValue"))) :
                                                    ExprSyntax(DeclReferenceExprSyntax(baseName: .identifier(entry.key))),
                                                trailingComma: i < attrEntries.count - 1 ? .commaToken() : nil
                                                )
                                            .with(\.leadingTrivia, .newline)
                                        }
                                    }
                                        .with(\.rightSquare, .rightSquareToken(leadingTrivia: .newline))
                                )
                                .with(\.leadingTrivia, .newline)
                            }
                        },
                        rightParen: .rightParenToken(leadingTrivia: .newline)
                    )
                }
                .with(\.leadingTrivia, docTrivia)
            }
        }
            .with(\.leadingTrivia, .newlines(2))
        return DeclSyntax(extensionDecl)
    }

    private static func safeCaseIdentifier(_ name: String) -> TokenSyntax {
        if name == "true" || name == "false" {
            return .identifier("`\(name)`")
        } else {
            return .identifier(name)
        }
    }

    // MARK: Documentation helpers

    private static func buildDocTrivia(description: String, newlinesBefore: Int = 1) -> Trivia {
        var pieces: [TriviaPiece] = [.newlines(newlinesBefore)]
        pieces.append(.docLineComment("/// \(description)"))
        pieces.append(.newlines(1))
        return Trivia(pieces: pieces)
    }

    private static func buildMethodDocTrivia(
            description: String?,
            params: [(name: String, type: String, description: String?)]
        ) -> Trivia {
            var pieces: [TriviaPiece] = [.newlines(2)]

            if let description {
                pieces.append(.docLineComment("/// \(description)"))
                pieces.append(.newlines(1))
            }

            let paramsWithDescs = params.filter { $0.description != nil }
            if !paramsWithDescs.isEmpty {
                pieces.append(.docLineComment("///"))
                pieces.append(.newlines(1))
                pieces.append(.docLineComment("/// - Parameters:"))
                pieces.append(.newlines(1))
                for param in params {
                    let paramDesc = param.description ?? param.name
                    pieces.append(.docLineComment("///   - \(param.name): \(paramDesc)"))
                    pieces.append(.newlines(1))
                }
            }

            return Trivia(pieces: pieces)
        }
}
