//
//  String+Extension.swift
//
//
//  Created by Tomasz Kucharski on 17/05/2022.
//

import Foundation

extension String {
    mutating func removeSubrange(_ range: ClosedRange<Int>) {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        self.removeSubrange(startIndex..<index(startIndex, offsetBy: range.count))
    }
}

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }

    subscript(range: Range<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }

    subscript(range: ClosedRange<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }

    subscript(range: PartialRangeFrom<Int>) -> String {
        String(self[index(startIndex, offsetBy: range.lowerBound)...])
    }

    subscript(range: PartialRangeThrough<Int>) -> String {
        String(self[...index(startIndex, offsetBy: range.upperBound)])
    }

    subscript(range: PartialRangeUpTo<Int>) -> String {
        String(self[..<index(startIndex, offsetBy: range.upperBound)])
    }
}
