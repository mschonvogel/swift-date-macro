import Foundation

@freestanding(expression)
public macro Date(iso8601 string: String) -> Date = #externalMacro(
    module: "DateMacroMacros",
    type: "ISO8601DateMacro"
)
