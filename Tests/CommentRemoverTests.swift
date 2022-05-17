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
        XCTAssertEqual(CommentRemover.removeComments(content), "")
    }

    func testSingleLineCommentWithTabs() {
        let content = "     // file that has only comment"
        XCTAssertEqual(CommentRemover.removeComments(content), "")
    }

    func testSingleLineCommentAfterCode() {
        let content = " var number = 21 // this should be removed"
        XCTAssertEqual(CommentRemover.removeComments(content), " var number = 21 ")
    }

    func testSingleLineCommentAtTheEndOfLine() {
        let content = " var number = 21 ///"
        XCTAssertEqual(CommentRemover.removeComments(content), " var number = 21 ")
    }

    func testSingleLineCommentInsideString() {
        let content = " var name = \"string with // slashes\""
        XCTAssertEqual(CommentRemover.removeComments(content), content)
    }

    func testMultilineCommentInOneLine() {
        let content = "var number = 12/* This is comment */"
        XCTAssertEqual(CommentRemover.removeComments(content), "var number = 12")
    }

    func testMultilineCommentInManyLines() {
        let content = """
        var number = 12/* This is comment
        next line of comment
        // nested one line comment
        */
        """
        XCTAssertEqual(CommentRemover.removeComments(content), "var number = 12")
    }
}
