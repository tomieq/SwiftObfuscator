//
//  ObjectTypeReplacerTests.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation
import XCTest
@testable import SwiftObfuscator

class ObjectTypeReplacerTests: XCTestCase {
    func testSimpleClassName() {
        let content = "final class User {}"
        let type = NamedType(flavor: .class, name: "User", modifiers: [])
        let replaced = ObjectTypeReplacer.replace(type, with: "Object1", in: content)
        XCTAssertEqual(replaced, "final class Object1 {}")
    }

    func testClassNameWithSuffix() {
        let content = """
            final class User {}
            class UserData {}
        """
        let type = NamedType(flavor: .class, name: "User", modifiers: [])
        let replaced = ObjectTypeReplacer.replace(type, with: "Object1", in: content)

        let expected = """
            final class Object1 {}
            class UserData {}
        """
        XCTAssertEqual(replaced, expected)
    }
}
