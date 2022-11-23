//
//  ConstantNameGenerator.swift
//
//
//  Created by Tomasz KUCHARSKI on 23/11/2022.
//

import Foundation

public class ConstantNameGenerator: NameGenerator {
    private var mapping: [String: String] = [:]

    public func generateTypeName(currentName: String) -> String {
        var suffix = ""
        let getNextName: () -> String = {
            "Memory0x" + self.crc(currentName) + suffix
        }
        var name = getNextName()
        var index = 0
        while self.mapping.values.contains(name) {
            suffix += name.subString(index, index + 1)
            index += 1
            name = getNextName()
        }
        self.mapping[currentName] = name
        return name
    }

    public func generatePrivateAttributeName(currentName: String) -> String {
        if currentName.hasPrefix("_") {
            return "_" + "pointer0x" + self.crc(currentName)
        }
        return "pointer0x" + self.crc(currentName)
    }

    public func generatePrivateFunctionName(currentName: String) -> String {
        return "malloc0x\(self.crc(currentName))"
    }

    private func crc(_ currentName: String) -> String {
        let crc = currentName.bytes.map{ Int($0) }.reduce(0, +)
        let left = String(crc.hex.reversed())

        let evenCrc = currentName.bytes.enumerated().filter{ $0.offset % 2 == 0 }.map{ Int($0.element) }.reduce(0, +)
        let central = String(evenCrc.hex.reversed())

        let thirdCrc = currentName.bytes.enumerated().filter{ $0.offset % 3 == 0 }.map{ Int($0.element) }.reduce(0, +)
        let right = String(thirdCrc.hex.reversed())
        return left.subString(0, 7) + central.subString(0, 7) + right.subString(0, 7)
    }
}
