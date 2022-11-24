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

    public func obfuscatePrivateAttributes() {
        let obfuscator = PrivateAttributeObfuscator(generateName: self.generatePrivateAttributeName)
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                obfuscator.obfuscate(swiftFile: file)
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
                obfuscator.obfuscate(swiftFile: file)
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
}
