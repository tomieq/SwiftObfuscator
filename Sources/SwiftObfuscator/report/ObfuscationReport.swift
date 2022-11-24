//
//  ObfuscationReport.swift
//
//
//  Created by Tomasz KUCHARSKI on 24/11/2022.
//

import Foundation

class ObfuscationReport: Codable {
    var files: [FileReport] = []
}

class FileReport: Codable {
    var file: String
    var privateAttributes: [MappingItem] = []
    var privateMethods: [MappingItem] = []
    var objects: [MappingItem] = []

    init(file: String) {
        self.file = file
    }
}
