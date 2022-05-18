//
//  ObjectTypeHarvesterTests.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation
import XCTest
@testable import SwiftObfuscator

class ObjectTypeHarvesterTests: XCTestCase {
    func testFindClassDefinition() {
        let content = """
            class User: Human {}
            class Dog {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.swiftObjectType, .class)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "User")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.swiftObjectType, .class)
        XCTAssertEqual(objectTypes[safeIndex: 1]?.name, "Dog")
    }

    func testFindStructDefinition() {
        let content = """
            struct Profile{}
            struct DefaultKeys {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.swiftObjectType, .struct)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "Profile")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.swiftObjectType, .struct)
        XCTAssertEqual(objectTypes[safeIndex: 1]?.name, "DefaultKeys")
    }

    func testFindProtocolDefinition() {
        let content = """
            protocol CaseIterable {}
            protocol Equatable {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.swiftObjectType, .protocol)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "CaseIterable")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.swiftObjectType, .protocol)
        XCTAssertEqual(objectTypes[safeIndex: 1]?.name, "Equatable")
    }

    func testFindEnumDefinition() {
        let content = """
            enum Size {
                case small
                case large
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.swiftObjectType, .enum)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "Size")
    }

    func testFindMixedDefinitions() {
        let content = """
            enum Alignment {
                case left
                case center
            }
            class View {
                var alignment: Alignment
            }
            struct Title {
                let label: String
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 3)
        XCTAssertTrue(objectTypes.contains(ProjectObjectType(swiftObjectType: .enum, name: "Alignment")))
        XCTAssertTrue(objectTypes.contains(ProjectObjectType(swiftObjectType: .class, name: "View")))
        XCTAssertTrue(objectTypes.contains(ProjectObjectType(swiftObjectType: .struct, name: "Title")))
    }

    func testClassMethodTrap() {
        let content = """
            class User {
                class func someMethod() {}
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 1)
    }
}
