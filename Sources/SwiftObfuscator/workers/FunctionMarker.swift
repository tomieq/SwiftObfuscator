//
//  FunctionMarker.swift
//  SwiftObfuscator
//
//  Created by Tomasz on 31/03/2025.
//
import Foundation

class FunctionMarker {
    private let logTag = "🐢 FunctionMarker"
    
    func addMarker(_ injection: String, swiftFile: SwiftFile, excludedFunctions: [String]) {
        let pattern = #"func\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)[^\{]*\{"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            Logger.e(self.logTag, "Invalid regular expression \(pattern)")
            return
        }
        let source = swiftFile.content
        var modifiedSource = swiftFile.content
        
        let matches = regex.matches(in: source, options: [], range: NSRange(source.startIndex..., in: source))
        
        for match in matches.reversed() {
            if let range = Range(match.range, in: source), let functionNameRange = Range(match.range(at: 1), in: source) {
                let functionName = String(source[functionNameRange])
                guard !excludedFunctions.contains(functionName) else {
                    continue
                }
                print("Injected into function: \(functionName)")
                let className = swiftFile.filename.components(separatedBy: ".")[0]
                let inject = "\tprint(\"🐀 invoke --> \(className).\(functionName)()\")"
                
                let insertPosition = source.distance(from: source.startIndex, to: range.upperBound)
                modifiedSource.insert(contentsOf: "\n    \(inject)", at: modifiedSource.index(modifiedSource.startIndex, offsetBy: insertPosition))
            }
        }
        swiftFile.content = modifiedSource
    }
}
