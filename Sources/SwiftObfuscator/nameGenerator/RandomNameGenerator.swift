//
//  RandomNameGenerator.swift
//
//
//  Created by Tomasz KUCHARSKI on 23/11/2022.
//

import Foundation

public class RandomNameGenerator {
    private var mapping: [String: String] = [:]

    public func generateTypeName(currentName: String) -> String {
        let getNextName: () -> String = {
            "MemorySpace0x".appendingRandomHexDigits(length: 12)
        }
        var name = getNextName()
        while self.mapping.values.contains(name) {
            name = getNextName()
        }
        self.mapping[currentName] = name
        return name
    }

    public func generatePrivateAttributeName(currentName: String) -> String {
        if currentName.hasPrefix("_") {
            return "_" + "pointer0x".appendingRandomHexDigits(length: 12)
        }
        return "pointer0x".appendingRandomHexDigits(length: 12)
    }

    public func generatePrivateFunctionName(currentName: String) -> String {
        "malloc0x".appendingRandomHexDigits(length: 12)
    }
}
