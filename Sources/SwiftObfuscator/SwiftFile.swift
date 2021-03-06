//
//  SwiftFile.swift
//
//
//  Created by Tomasz on 17/05/2022.
//

import Foundation

class SwiftFile {
    let filePath: String
    let filename: String
    var content: String

    init(filePath: String, content: String) {
        self.filePath = filePath
        self.filename = filePath.components(separatedBy: "/").last ?? ""
        self.content = content
    }
}
