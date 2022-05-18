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

struct NamedType: Equatable, Hashable {
    let flavor: ObjectTypeFlavor
    let name: String
}

struct ObjectTypeHarvester {
    static func getObjectTypes(fileContent txt: String) -> [NamedType] {
        var foundTypes: [NamedType] = []
        let range = NSRange(location: 0, length: txt.utf16.count)

        for flavor in ObjectTypeFlavor.allCases {
            let flavorName = flavor.rawValue
            guard let regex = try? NSRegularExpression(pattern: "\\b\(flavorName)\\s[A-Z][a-zA-Z0-9_]+") else {
                continue
            }
            for result in regex.matches(in: txt, options: [], range: range) {
                let matchingString = (txt as NSString).substring(with: result.range)
                let nameRange = flavorName.count...matchingString.count - 1
                let name = matchingString[nameRange].trimmingCharacters(in: .whitespaces)
                foundTypes.append(NamedType(flavor: flavor, name: name))
            }
        }

        return foundTypes
    }
}
