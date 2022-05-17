//
//  SwiftFileHarvester.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

class SwiftFileHarvester {
    let absolutePath: String

    init(absolutePath: String) {
        self.absolutePath = absolutePath
    }

    func getFiles() -> [SwiftFile] {
        let files = try? FileManager.default.subpathsOfDirectory(atPath: self.absolutePath)
            .filter { $0.hasSuffix(".swift") }
            .compactMap { (path: String) -> SwiftFile? in
                let absolutePath = "\(self.absolutePath)/\(path)"
                guard let content = try? String(contentsOfFile: absolutePath) else {
                    print("Could not read content of \(path)")
                    return nil
                }
                return SwiftFile(filePath: path, content: content)
            }
        return files ?? []
    }
}
