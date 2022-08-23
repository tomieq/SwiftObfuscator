//
//  ObjectTypeReplacer.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

enum ObjectTypeReplacer {
    static func replace(_ type: NamedType, with name: String, in fileContent: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\b\(type.name)\\b") else {
            return fileContent
        }
        let range = NSRange(location: 0, length: fileContent.utf16.count)
        return regex.stringByReplacingMatches(in: fileContent, options: [], range: range, withTemplate: name)
    }
}
