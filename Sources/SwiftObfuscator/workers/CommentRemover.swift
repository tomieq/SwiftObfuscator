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
                if let index = line.in
                    return "\(line[...index])"
                }
                return line
            }
        let content = linesWithoutComment.joined(separator: "\n")
        return SwiftFile(filename: file.filename, content: content)
    }
}
