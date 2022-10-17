//
//  ProjectFileLoader.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

class ProjectFiles {
    var swiftFiles: [SwiftFile]
    var coreDataFiles: [String]

    init() {
        self.swiftFiles = []
        self.coreDataFiles = []
    }
}

enum ProjectFileLoader {
    private static let logTag = "🐣 ProjectFileLoader"
    static func loadFiles(from absolutePath: String) -> ProjectFiles {
        let filePaths = (try? FileManager.default.subpathsOfDirectory(atPath: absolutePath)) ?? []

        let projectFiles = ProjectFiles()
        projectFiles.swiftFiles = filePaths
            .filter { $0.hasSuffix(".swift") }
            .compactMap { (filePath: String) -> SwiftFile? in
                let absoluteFilePath = "\(absolutePath)/\(filePath)"
                guard let content = try? String(contentsOfFile: absoluteFilePath) else {
                    Logger.e(Self.logTag, "Could not read content of \(filePath)")
                    return nil
                }
                return SwiftFile(filePath: filePath, content: content)
            }
        Logger.v(self.logTag, "Loaded \(projectFiles.swiftFiles.count) swift files")
        return projectFiles
    }
}
