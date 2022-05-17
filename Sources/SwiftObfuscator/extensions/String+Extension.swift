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
