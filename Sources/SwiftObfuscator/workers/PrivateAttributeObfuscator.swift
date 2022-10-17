//
//  PrivateAttributeObfuscator.swift
//
//
//  Created by Tomasz Kucharski on 18/05/2022.
//

import Foundation

enum VariableType: String {
    case `let`
    case `var`
}

struct PrivateVariable: Hashable {
    let type: VariableType
    let name: String
}

class PrivateAttributeObfuscator {
    let generateName: (String) -> String
    
    init(generateName: @escaping (String) -> String) {
        self.generateName = generateName
    }

    func obfuscate(swiftFile: SwiftFile) {
        let txt = swiftFile.content
        let range = NSRange(location: 0, length: txt.utf16.count)

        var mapping: [PrivateVariable: String] = [:]

        let pattern = "\\b(private|fileprivate)+\\s(let|var)+\\s[a-zA-Z0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Invalid regular expression")
            return
        }

        for result in regex.matches(in: txt, options: [], range: range) {
            let matchingString = (txt as NSString).substring(with: result.range)
            let parts = matchingString.components(separatedBy: .whitespacesAndNewlines)
            guard let name = parts[safeIndex: 2],
                  let type = parts[safeIndex: 1],
                  let variableType = VariableType(rawValue: type) else {
                continue
            }
            let variable = PrivateVariable(type: variableType, name: name)
            if mapping.keys.contains(variable).not {
                mapping[variable] = self.generateName(name)
            }
        }
        for (variable, newName) in mapping {
            let rules: [(pattern: String, replacement: String)] = [
                ("\\b\(variable.type.rawValue)\\s\(variable.name)\\b", "\(variable.type.rawValue) \(newName)"),
                ("\\bself\\.\(variable.name)\\b", "self.\(newName)"),
                ("self\\?\\.\(variable.name)\\b", "self?.\(newName)")
            ]
            for rule in rules {
                guard let regex = try? NSRegularExpression(pattern: rule.pattern) else {
                    print("Error in regex pattern \(pattern)")
                    continue
                }
                let range = NSRange(location: 0, length: swiftFile.content.utf16.count)
                swiftFile.content = regex.stringByReplacingMatches(in: swiftFile.content, range: range, withTemplate: rule.replacement)
            }
        }
    }
}
