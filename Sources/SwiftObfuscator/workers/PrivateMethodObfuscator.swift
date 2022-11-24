//
//  PrivateMethodObfuscator.swift
//
//
//  Created by Tomasz Kucharski on 18/05/2022.
//

import Foundation

struct PrivateMethod: Hashable {
    let type: String
    let name: String
}

class PrivateMethodObfuscator {
    private let logTag = "🐢 PrivateMethodObfuscator"
    var generateName: (String) -> String

    init(generateName: @escaping (String) -> String) {
        self.generateName = generateName
    }

    func obfuscate(swiftFile: SwiftFile) -> [PrivateMethod: String] {
        var mapping: [PrivateMethod: String] = [:]

        let pattern = "(private|fileprivate)+\\sfunc\\s[a-zA-Z0-9_]+\\("
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            Logger.e(self.logTag, "Invalid regular expression \(pattern)")
            return mapping
        }
        let range = NSRange(location: 0, length: swiftFile.content.utf16.count)
        let matches = regex.matches(in: swiftFile.content, options: [], range: range)
        for result in matches {
            let matchingString = (swiftFile.content as NSString).substring(with: result.range)
            let parts = matchingString.components(separatedBy: .whitespacesAndNewlines)
            guard let name = parts[safeIndex: 2]?.trimmingCharacters(in: CharacterSet(charactersIn: "(")),
                  let type = parts[safeIndex: 0] else {
                continue
            }
            let method = PrivateMethod(type: type, name: name)
            if mapping.keys.contains(method).not {
                mapping[method] = self.generateName(name)
            }
        }

        for (method, newName) in mapping {
            Logger.v(self.logTag, "Method \(method.name) replaced with \(newName) in \(swiftFile.filename)")
            let rules: [(pattern: String, replacement: String)] = [
                ("\\b\(method.type)\\sfunc\\s\(method.name)\\(", "\(method.type) func \(newName)("),
                ("\\bself\\.\(method.name)\\b", "self.\(newName)"),
                ("self\\?\\.\(method.name)\\b", "self?.\(newName)"),
                ("\\#selector\\(\(method.name)\\(", "#selector(\(newName)(")
            ]
            for rule in rules {
                guard let regex = try? NSRegularExpression(pattern: rule.pattern) else {
                    print("Error in regex pattern \(pattern)")
                    continue
                }
                let range = NSRange(location: 0, length: swiftFile.content.utf16.count)
                swiftFile.content = regex.stringByReplacingMatches(in: swiftFile.content, range: range, withTemplate: rule.replacement)
            }
            print("Renamed private method \(method.name) into \(newName) in file \(swiftFile.filename)")
        }
        return mapping
    }
}
