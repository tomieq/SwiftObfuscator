//
//  CommentRemover.swift
//
//
//  Created by Tomasz on 17/05/2022.
//

import Foundation

struct CommentRemover {
    static func removeComments(_ content: String) -> String {
        var content = content
        while let openIndex = content.getFirstIndex(for: .openMultiline),
              let closeIndex = content.getFirstIndex(for: .closeMultiline) {
            content.removeSubrange(openIndex...closeIndex + 1)
        }
        let lines = content.components(separatedBy: .newlines)
        let linesWithoutComment = lines
            .filter {
                $0.trimmingCharacters(in: .whitespaces)
                    .starts(with: "//")
                    .not
            }
            .map { (line: String) -> String in
                if let index = line.getFirstIndex(for: .singleLine) {
                    return "\(line[0...index - 1])"
                }
                return line
            }
        return linesWithoutComment.joined(separator: "\n")
    }
}

fileprivate enum CommentSign {
    case singleLine
    case openMultiline
    case closeMultiline

    var sign: (Character, Character) {
        switch self {
        case .singleLine:
            return ("/", "/")
        case .openMultiline:
            return ("/", "*")
        case .closeMultiline:
            return ("*", "/")
        }
    }
}

fileprivate extension String {
    func getFirstIndex(for type: CommentSign) -> Int? {
        var isInsideQuote = false
        let expected = type.sign
        for (index, character) in self.enumerated() {
            let nextIndex = index + 1
            if character == "\"" { isInsideQuote.toggle() }
            if character == expected.0, isInsideQuote.not, nextIndex < self.count, self[nextIndex] == expected.1 {
                return index
            }
        }
        return nil
    }
}
