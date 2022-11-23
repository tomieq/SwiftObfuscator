//
//  Int+Extension.swift
//  
//
//  Created by Tomasz KUCHARSKI on 23/11/2022.
//

import Foundation

extension Int {
    var hex: String {
        String(format: "%02x", self)
    }
}
