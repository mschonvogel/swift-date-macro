import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

/// Expands the `#ISO8601Date` freestanding macro into a `Date` literal at compile time.
///
/// This macro takes a single string literal in ISO 8601 format and converts it into a
/// `Date(timeIntervalSinceReferenceDate:)` expression whose value is determined at compile time.
/// This eliminates the need to parse the date at runtime, improving performance and avoiding
/// potential runtime errors for invalid date strings.
///
/// - Example:
///   ```swift
///   let date = #ISO8601Date("2025-08-12T14:30:00Z")
///   // Expands to:
///   // let date = Date(timeIntervalSinceReferenceDate: 773164200.0)
///   ```
public struct ISO8601DateMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let arg = node.argumentList.first?.expression.as(StringLiteralExprSyntax.self),
              let isoString = arg.segments.first?.description.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            throw MacroError.message("Expected a string literal")
        }

        let formatter = ISO8601DateFormatter()

        if isoString.last == "Z" {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        }

        guard let date = formatter.date(from: isoString) else {
            throw MacroError.message("Invalid ISO8601 date: \(isoString)")
        }

        let timeInterval = date.timeIntervalSinceReferenceDate
        return "Date(timeIntervalSinceReferenceDate: \(raw: timeInterval))"
    }
}

enum MacroError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case .message(let msg):
            return msg
        }
    }
}

@main
struct DateMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ISO8601DateMacro.self,
    ]
}
