//
//  CommentRemoverTests.swift
//
//
//  Created by Tomasz on 17/05/2022.
//

import Foundation
import XCTest
@testable import SwiftObfuscator

class CommentRemoverTests: XCTestCase {
    func testRemoveOneSingleLineComment() {
        let content = "// file that has only comment"
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "")
    }

    func testSingleLineCommentWithTabs() {
        let content = "     // file that has only comment"
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "")
    }

    func testSingleLineCommentAfterCode() {
        let content = " var number = 21 // this should be removed"
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, " var number = 21 ")
    }

    func testSingleLineCommentAtTheEndOfLine() {
        let content = " var number = 21 ///"
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, " var number = 21 ")
    }

    func testSingleLineCommentInsideString() {
        let content = " var name = \"string with // slashes\""
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, content)
    }

    func testMultilineCommentInOneLine() {
        let content = "var number = 12/* This is comment */"
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "var number = 12")
    }

    func testMultilineCommentInManyLines() {
        let content = """
        var number = 12/* This is comment
        next line of comment
        // nested one line comment
        */
        """
        let file = SwiftFile(filePath: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "var number = 12")
    }
}
