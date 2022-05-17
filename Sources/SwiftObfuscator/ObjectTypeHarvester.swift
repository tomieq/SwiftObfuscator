//
//  ObjectTypeHarvester.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

enum SwiftObjectType: String, CaseIterable {
    case `class`
    case `enum`
    case `struct`
}

struct ProjectObjectType: Equatable {
    let swiftObjectType: SwiftObjectType
    let name: String
}

class ObjectTypeHarvester {
    static func getObjectTypes(fileContent txt: String) -> [ProjectObjectType] {
        var foundObjectTypes: [ProjectObjectType] = []
        let range = NSRange(location: 0, length: txt.utf16.count)

        for type in SwiftObjectType.allCases {
            let rawType = type.rawValue
            guard let regex = try? NSRegularExpression(pattern: "\\b\(rawType)\\s[A-Z][a-zA-Z0-9_]+") else {
                continue
            }
            for result in regex.matches(in: txt, options: [], range: range) {
                let matchingString = (txt as NSString).substring(with: result.range)
                let name = matchingString[rawType.count...matchingString.count - 1].trimmingCharacters(in: .whitespaces)
                foundObjectTypes.append(ProjectObjectType(swiftObjectType: type, name: name))
            }
        }

        return foundObjectTypes
    }
}
