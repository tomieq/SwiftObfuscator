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
}
