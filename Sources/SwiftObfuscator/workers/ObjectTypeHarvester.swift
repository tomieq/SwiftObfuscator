//
//  ObjectTypeHarvester.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

enum ObjectTypeFlavor: String, CaseIterable {
    case `class`
    case `enum`
    case `struct`
    case `protocol`
}

enum ObjectTypeModifier: String, CaseIterable {
    case final
    case `public`
    case `internal`
    case `private`
    case `fileprivate`
}

struct NamedType: Equatable, Hashable {
    let flavor: ObjectTypeFlavor
    let name: String
    let modifiers: [ObjectTypeModifier]
}

struct ObjectTypeHarvester {
    static func getObjectTypes(fileContent txt: String) -> [NamedType] {
        var foundTypes: [NamedType] = []
        let range = NSRange(location: 0, length: txt.utf16.count)

        let modifiers = ObjectTypeModifier.allCases.map { $0.rawValue }.joined(separator: "|")
        for flavor in ObjectTypeFlavor.allCases {
            let flavorName = flavor.rawValue
            let pattern = "(\(modifiers)|\\s)*\\s\(flavorName)\\s[A-Z][a-zA-Z0-9_]+"
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                continue
            }
            for result in regex.matches(in: txt, options: [], range: range) {
                let matchingString = (txt as NSString).substring(with: result.range)
                let splitted = matchingString.components(separatedBy: flavorName)
                let usedMofifiers = splitted[0]
                    .components(separatedBy: .whitespacesAndNewlines)
                    .compactMap { ObjectTypeModifier(rawValue: $0) }
                let name = splitted[1].trimmingCharacters(in: .whitespacesAndNewlines)
                foundTypes.append(NamedType(flavor: flavor, name: name, modifiers: usedMofifiers))
            }
        }

        return foundTypes
    }
}
