//
//  Project.swift
//
//
//  Created by Tomasz Kucharski on 18/05/2022.
//

import Foundation

public class Project {
    let absolutePath: String
    let projectFiles: ProjectFiles
    private(set) var mapping: [NamedType: String] = [:]
    private var excludedFilePaths: [String]

    public init(absolutePath: String) {
        self.absolutePath = absolutePath
        self.projectFiles = ProjectFileLoader.loadFiles(from: absolutePath)
        self.excludedFilePaths = []
    }

    public func addExcludedPath(_ path: String) {
        self.excludedFilePaths.append(path)
    }
    
    private func isFileExcluded(filePath: String) -> Bool {
        for excludedPath in self.excludedFilePaths {
            if filePath.contains(excludedPath) {
                return true
            }
        }
        return false
    }
    
    public func removeComments() {
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
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                let types = ObjectTypeHarvester.getObjectTypes(fileContent: file.content)
                for type in types {
                    if type.isPublic.not,
                       self.mapping.keys.contains(type).not,
                       untouchableTypeNames.contains(type.name).not {
                        let replacement = self.makeObjectTypeName(type.name)
                        self.mapping[type] = replacement
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
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                PrivateAttributeObfuscator.obfuscate(swiftFile: file)
            }
        }
    }

    public func obfuscatePrivateMethods() {
        for file in self.projectFiles.swiftFiles {
            if self.isFileExcluded(filePath: file.filePath) {
                continue
            }
            autoreleasepool {
                PrivateMethodObfuscator.obfuscate(swiftFile: file)
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

    private func makeObjectTypeName(_ name: String) -> String {
        self.randomName()
    }

    private func randomName() -> String {
        let getNextName: () -> String = {
            "MemorySpace0x".appendingRandomHexDigits(length: 12)
        }
        var name = getNextName()
        while self.mapping.values.contains(name) {
            name = getNextName()
        }
        return name
    }
}
