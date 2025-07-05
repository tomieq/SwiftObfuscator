//
//  Project.swift
//
//
//  Created by Tomasz Kucharski on 18/05/2022.
//

import Foundation

public class Project {
    private let logTag = "🐓 Project"
    let absolutePath: String
    let projectFiles: ProjectFiles
    private(set) var mapping: [NamedType: String] = [:]
    // private attribute mapping by path
    private var privateAttributes: [String: [PrivateVariable: String]] = [:]
    // private method mapping by path
    private var privateMethods: [String: [PrivateMethod: String]] = [:]
    // object type mapping by path
    private var objectTypes: [String: [NamedType: String]] = [:]

    private var excludedFolders: [String]
    private var excludedFileNames: [String]

    var generateTypeName: (String) -> String
    var generatePrivateAttributeName: (String) -> String
    var generatePrivateFunctionName: (String) -> String

    public init(absolutePath: String) {
        self.absolutePath = absolutePath
        self.projectFiles = ProjectFileLoader.loadFiles(from: absolutePath)
        self.excludedFolders = []
        self.excludedFileNames = []

        let nameGenerator = ConstantNameGenerator()
        self.generateTypeName = nameGenerator.generateTypeName(currentName:)
        self.generatePrivateAttributeName = nameGenerator.generatePrivateAttributeName(currentName:)
        self.generatePrivateFunctionName = nameGenerator.generatePrivateFunctionName(currentName:)

        Logger.v(self.logTag, "Loaded \(self.projectFiles.swiftFiles.count) swift files")
    }

    public func excludeFolder(_ path: String) {
        let path = path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/"
        self.excludedFolders.append(path)
        Logger.v(self.logTag, "Added excluded folder: \(path)")
    }

    public func excludeFile(filename: String) {
        let filename = filename.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        self.excludedFileNames.append(filename)
        Logger.v(self.logTag, "Added excluded filename: \(filename)")
    }

    private func isFileExcluded(filePath: String) -> Bool {
        for excludedPath in self.excludedFolders {
            if filePath.hasPrefix(excludedPath) {
                return true
            }
        }
        for excludedFile in self.excludedFileNames {
            let components = filePath.split(separator: "/")
            if let name = components.last, excludedFile == "\(name)" {
                return true
            }
        }
        return false
    }

    public func removeComments() {
        Logger.v(self.logTag, "Removing comments")
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                file.content = CommentRemover.removeComments(file.content)
            }
        }
    }

    public func obfuscateObjectTypeNames(untouchableTypeNames: [String]) {
        Logger.v(self.logTag, "Obfuscating type names")
        let swiftProtectedNames = ["CodingKeys"]
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                Logger.v(self.logTag, "Skip file \(file.filePath)")
                continue
            }
            autoreleasepool {
                Logger.v(self.logTag, "Parsing file \(file.filePath)")
                let types = ObjectTypeHarvester.getObjectTypes(fileContent: file.content)
                for type in types {
                    if type.isPublic.not,
                       self.mapping.keys.contains(type).not,
                       swiftProtectedNames.contains(type.name).not,
                       untouchableTypeNames.contains(type.name).not {
                        let replacement = self.generateTypeName(type.name)
                        self.mapping[type] = replacement
                        self.objectTypes[file.filePath, default: [:]][type] = replacement
                        Logger.v(self.logTag, "Type \(type.name) replaced with \(replacement)")
                    }
                }
            }
        }

        self.projectFiles.swiftFiles.forEach { file in
            autoreleasepool {
                for (type, value) in mapping {
                    file.content = ObjectTypeReplacer.replace(type, with: value, in: file.content)
                }
            }
        }
    }
    
    public func addPrintMarker(excludedFunctions: [String]) {
        let marker = FunctionMarker()
        for file in self.projectFiles.swiftFiles {
            print("Processing \(file.filename)")
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                marker.addMarker("", swiftFile: file, excludedFunctions: excludedFunctions)
            }
        }
    }

    public func obfuscatePrivateAttributes() {
        let obfuscator = PrivateAttributeObfuscator(generateName: self.generatePrivateAttributeName)
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                self.privateAttributes[file.filePath] = obfuscator.obfuscate(swiftFile: file)
            }
        }
    }

    public func obfuscatePrivateMethods() {
        let obfuscator = PrivateMethodObfuscator(generateName: self.generatePrivateFunctionName)
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                self.privateMethods[file.filePath] = obfuscator.obfuscate(swiftFile: file)
            }
        }
    }

    public func applyCustomTransformation(_ transform: (_ filePath: String, _ content: String) -> String) {
        for file in self.projectFiles.swiftFiles {
            autoreleasepool {
                file.content = transform(file.filePath, file.content)
            }
        }
    }

    public func overrideFiles() {
        self.projectFiles.swiftFiles.forEach { file in
            autoreleasepool {
                let newPath = self.absolutePath + "/" + file.filePath
                let directory = URL(fileURLWithPath: newPath).deletingLastPathComponent()
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                FileManager.default.createFile(atPath: newPath, contents: file.content.data(using: .utf8))
            }
        }
    }

    public var report: String {
        let report = ObfuscationReport()

        func getFileReport(_ file: String) -> FileReport {
            var fileReport = report.files.first{ $0.file == file }
            if fileReport.isNil {
                fileReport = FileReport(file: file)
                report.files.append(fileReport!)
            }
            return fileReport!
        }

        for (file, dictionary) in self.privateMethods {
            let fileReport = getFileReport(file)
            var privateMethods: [MappingItem] = []
            for (method, newName) in dictionary {
                privateMethods.append(MappingItem(originalName: method.name, obfuscatedName: newName))
            }
            fileReport.privateMethods = privateMethods
        }

        for (file, dictionary) in self.privateAttributes {
            let fileReport = getFileReport(file)
            var privateAttributes: [MappingItem] = []
            for (attribute, newName) in dictionary {
                privateAttributes.append(MappingItem(originalName: attribute.name, obfuscatedName: newName))
            }
            fileReport.privateAttributes = privateAttributes
        }

        for (file, dictionary) in self.objectTypes {
            let fileReport = getFileReport(file)
            var objectTypes: [MappingItem] = []
            for (namedType, newName) in dictionary {
                objectTypes.append(MappingItem(originalName: namedType.name, obfuscatedName: newName))
            }
            fileReport.objects = objectTypes
        }
        return report.json
    }
}
