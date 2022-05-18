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

    init(absolutePath: String) {
        self.absolutePath = absolutePath
        self.projectFiles = ProjectFileLoader.loadFiles(from: absolutePath)
    }

    func removeComments() {
        self.projectFiles.swiftFiles.forEach { file in
            autoreleasepool {
                file.content = CommentRemover.removeComments(file.content)
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
}
