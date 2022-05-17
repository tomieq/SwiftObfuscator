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
        let file = SwiftFile(filename: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "")
    }

    func testSingleLineCommentWithTabs() {
        let content = "     // file that has only comment"
        let file = SwiftFile(filename: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, "")
    }
    
    func testSingleLineCommentAfterCode() {
        let content = " var number = 21 // this should be removed"
        let file = SwiftFile(filename: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, " var number = 21 ")
    }
    
    func testSingleLineCommentAtTheEndOfLine() {
        let content = " var number = 21 ///"
        let file = SwiftFile(filename: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, " var number = 21 ")
    }
    
    func testSingleLineCommentInsideString() {
        let content = " var name = \"string with // slashes\""
        let file = SwiftFile(filename: "main.swift", content: content)
        let cleanFile = CommentRemover.removeComments(file)
        XCTAssertEqual(cleanFile.content, content)
    }
}
