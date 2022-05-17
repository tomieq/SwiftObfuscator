//
//  CommentRemover.swift
//
//
//  Created by Tomasz on 17/05/2022.
//

import Foundation

struct CommentRemover {
    private enum CommentSign {
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

    static func removeComments(_ file: SwiftFile) -> SwiftFile {
        let lines = file.content.components(separatedBy: .newlines)
        let linesWithoutComment = lines
            .filter {
                !$0.trimmingCharacters(in: .whitespaces)
                    .starts(with: "//")
            }
            .map { (line: String) -> String in
                if let index = self.getCommentIndex(.singleLine, in: line) {
                    return "\(line[0...index - 1])"
                }
                return line
            }
        let content = linesWithoutComment.joined(separator: "\n")
        return SwiftFile(filename: file.filename, content: content)
    }

    private static func getCommentIndex(_ type: CommentSign, in line: String) -> Int? {
        var isInsideQuote = false
        let expected = type.sign
        for (index, character) in line.enumerated() {
            let nextIndex = index + 1
            if character == "\"" { isInsideQuote.toggle() }
            if character == expected.0, isInsideQuote.not, nextIndex < line.count, line[nextIndex] == expected.1 {
                return index
            }
        }
        return nil
    }
}
