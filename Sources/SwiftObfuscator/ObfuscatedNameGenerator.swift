//
//  ObfuscatedNameGenerator.swift
//
//
//  Created by Tomasz KUCHARSKI on 17/10/2022.
//

import Foundation

class ObfuscatedNameGenerator {
    private var mapping: [NamedType: String] = [:]

    func generateTypeName(currentName: String) -> String {
        let getNextName: () -> String = {
            "MemorySpace0x".appendingRandomHexDigits(length: 12)
        }
        var name = getNextName()
        while self.mapping.values.contains(name) {
            name = getNextName()
        }
        return name
    }

    func generatePrivateAttributeName(currentName: String) -> String {
        if currentName.hasPrefix("_") {
            return "_" + "pointer0x".appendingRandomHexDigits(length: 12)
        }
        return "pointer0x".appendingRandomHexDigits(length: 12)
    }

    func generatePrivateFunctionName(currentName: String) -> String {
        "malloc0x".appendingRandomHexDigits(length: 12)
    }
}
