//
//  Project.swift
//
//
//  Created by Tomasz Kucharski on 18/05/2022.
//

import Foundation

class Project {
    let absolutePath: String
    let projectFiles: ProjectFiles
    private(set) var mapping: [NamedType: String] = [:]

    init(absolutePath: String) {
        self.absolutePath = absolutePath
        self.projectFiles = ProjectFileLoader.loadFiles(from: absolutePath)
    }

    func removeComments() {
        for file in self.projectFiles.swiftFiles {
            autoreleasepool {
                file.content = CommentRemover.removeComments(file.content)
            }
        }
    }

    func obfuscateObjectTypeNames(untouchableTypeNames: [String]) {
        for file in self.projectFiles.swiftFiles {
            autoreleasepool {
                let types = ObjectTypeHarvester.getObjectTypes(fileContent: file.content)
                for type in types {
                    if type.isPublic.not,
                       self.mapping.keys.contains(type).not,
                       untouchableTypeNames.contains(type.name).not {
                        let replacement = self.makeObjectTypeName(type.name)
                        mapping[type] = replacement
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

    func obfuscatePrivateAttributes() {
        for file in self.projectFiles.swiftFiles {
            autoreleasepool {
                PrivateAttributeObfuscator.obfuscate(swiftFile: file)
            }
        }
    }

    func obfuscatePrivateMethods() {
        for file in self.projectFiles.swiftFiles {
            autoreleasepool {
                PrivateMethodObfuscator.obfuscate(swiftFile: file)
            }
        }
    }

    func overrideFiles() {
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
