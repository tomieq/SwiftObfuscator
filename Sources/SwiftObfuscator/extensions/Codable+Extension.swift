//
//  Codable+Extension.swift
//
//
//  Created by Tomasz KUCHARSKI on 24/11/2022.
//

import Foundation

extension Encodable {
    var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else {
            return "{}"
        }
        return String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/") ?? "{}"
    }
}
