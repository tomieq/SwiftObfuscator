//
//  CommentRemover.swift
//
//
//  Created by Tomasz on 17/05/2022.
//

import Foundation

struct CommentRemover {
    static func removeComments(_ file: SwiftFile) -> SwiftFile {
        let lines = file.content.components(separatedBy: .newlines)
        let linesWithoutComment = lines
            .filter {
                !$0.trimmingCharacters(in: .whitespaces)
                    .starts(with: "//")
            }
            .map { (line: String) -> String in
                if let index = self.getSingleLineCommentIndex(line) {
                    return "\(line[0...index - 1])"
                }
                return line
            }
        let content = linesWithoutComment.joined(separator: "\n")
        return SwiftFile(filename: file.filename, content: content)
    }

    private static func getSingleLineCommentIndex(_ line: String) -> Int? {
        var isInsideQuote = false
        for (index, character) in line.enumerated() {
            let nextIndex = index + 1
            if character == "\"" { isInsideQuote.toggle() }
            if character == "/", isInsideQuote.not, nextIndex < line.count, line[nextIndex] == "/" {
                return index
            }
        }
        return nil
    }
}
