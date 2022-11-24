//
//  Optional+Extension.swift
//
//
//  Created by Tomasz KUCHARSKI on 24/11/2022.
//

import Foundation

extension Optional {
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }
}
