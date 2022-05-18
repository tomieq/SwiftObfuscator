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
            public final a class User: Human {}
            class Dog {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.flavor, .class)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "User")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.flavor, .class)
        XCTAssertEqual(objectTypes[safeIndex: 1]?.name, "Dog")
    }

    func testFindStructDefinition() {
        let content = """
            struct Profile{}
            struct DefaultKeys {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.flavor, .struct)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "Profile")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.flavor, .struct)
        XCTAssertEqual(objectTypes[safeIndex: 1]?.name, "DefaultKeys")
    }

    func testFindProtocolDefinition() {
        let content = """
            protocol CaseIterable {}
            protocol Equatable {}
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.flavor, .protocol)
        XCTAssertEqual(objectTypes[safeIndex: 0]?.name, "CaseIterable")
        XCTAssertEqual(objectTypes[safeIndex: 1]?.flavor, .protocol)
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
        XCTAssertEqual(objectTypes[safeIndex: 0]?.flavor, .enum)
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
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .enum, name: "Alignment", modifiers: [])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "View", modifiers: [])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .struct, name: "Title", modifiers: [])))
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

    func testFinalModifier() {
        let content = """
            final class Obfuscator {
                var files: Files
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 1)
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "Obfuscator", modifiers: [.final])))
    }

    func testPublicModifier() {
        let content = """
            public class API {
                var files: Files
            }
            public struct Constants {
                let width = 80
            }
            public protocol APIService {
                func load()
            }
            public enum Env {
                case prod
                case uat
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 4)
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "API", modifiers: [.public])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .struct, name: "Constants", modifiers: [.public])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .protocol, name: "APIService", modifiers: [.public])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .enum, name: "Env", modifiers: [.public])))
    }

    func testPrivateModifier() {
        let content = """
            private class API {
                var files: Files
            }
            private struct Constants {
                let width = 80
            }
            private protocol APIService {
                func load()
            }
            private enum Env {
                case prod
                case uat
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 4)
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "API", modifiers: [.private])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .struct, name: "Constants", modifiers: [.private])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .protocol, name: "APIService", modifiers: [.private])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .enum, name: "Env", modifiers: [.private])))
    }

    func testFilePrivateModifier() {
        let content = """
            fileprivate class API {
                var files: Files
            }
            fileprivate struct Constants {
                let width = 80
            }
            fileprivate protocol APIService {
                func load()
            }
            fileprivate enum Env {
                case prod
                case uat
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 4)
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "API", modifiers: [.fileprivate])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .struct, name: "Constants", modifiers: [.fileprivate])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .protocol, name: "APIService", modifiers: [.fileprivate])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .enum, name: "Env", modifiers: [.fileprivate])))
    }

    func testMultipleModifiers() {
        let content = """
            final public class API {
                var files: Files
            }
            public final class URLFetcher {
                func fetch()
            }
        """
        let objectTypes = ObjectTypeHarvester.getObjectTypes(fileContent: content)
        XCTAssertEqual(objectTypes.count, 2)
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "API", modifiers: [.final, .public])))
        XCTAssertTrue(objectTypes.contains(NamedType(flavor: .class, name: "URLFetcher", modifiers: [.public, .final])))
    }
}
