//
//  PrivateAttributeObfuscatorTests.swift
//
//
//  Created by Tomasz KUCHARSKI on 21/11/2022.
//

import Foundation
import XCTest
@testable import SwiftObfuscator

class PrivateAttributeObfuscatorTests: XCTestCase {
    func test_obfuscatePrivateAttribute() throws {
        let sut = PrivateAttributeObfuscator { _ in
            return "replaced"
        }
        let code = """
        class Car {
            private let original = "some original text"
            func replace() {
                self.original = "original"
                print(self.original.count)
            }
        }
        """
        let swiftFile = SwiftFile(filePath: "tmp.swift", content: code)
        let report = sut.obfuscate(swiftFile: swiftFile)

        let obfuscated = """
        class Car {
            private let replaced = "some original text"
            func replace() {
                self.replaced = "original"
                print(self.replaced.count)
            }
        }
        """
        XCTAssertEqual(obfuscated, swiftFile.content)
        XCTAssertEqual(report, [PrivateVariable(type: .let, name: "original"): "replaced"])
    }

    func test_obfuscateWeakPrivateAttribute() throws {
        let sut = PrivateAttributeObfuscator { _ in
            return "replaced"
        }
        let code = """
        class Car {
            private let original = "some original text"
            func replace() {
                self?.original = "original"
                print(self.original?.count)
            }
        }
        """
        let swiftFile = SwiftFile(filePath: "tmp.swift", content: code)
        let report = sut.obfuscate(swiftFile: swiftFile)

        let obfuscated = """
        class Car {
            private let replaced = "some original text"
            func replace() {
                self?.replaced = "original"
                print(self.replaced?.count)
            }
        }
        """
        XCTAssertEqual(obfuscated, swiftFile.content)
        XCTAssertEqual(report, [PrivateVariable(type: .let, name: "original"): "replaced"])
    }

    func test_obfuscateForceUnwrappedPrivateAttribute() throws {
        let sut = PrivateAttributeObfuscator { _ in
            return "replaced"
        }
        let code = """
        class Car {
            private let original = "some original text"
            func replace() {
                self!.original = "original"
                print(self.original!.count)
            }
        }
        """
        let swiftFile = SwiftFile(filePath: "tmp.swift", content: code)
        let report = sut.obfuscate(swiftFile: swiftFile)

        let obfuscated = """
        class Car {
            private let replaced = "some original text"
            func replace() {
                self!.replaced = "original"
                print(self.replaced!.count)
            }
        }
        """
        XCTAssertEqual(obfuscated, swiftFile.content)
        XCTAssertEqual(report, [PrivateVariable(type: .let, name: "original"): "replaced"])
    }
}
