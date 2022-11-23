//
//  NameGenerator.swift
//
//
//  Created by Tomasz KUCHARSKI on 23/11/2022.
//

import Foundation

protocol NameGenerator {
    func generateTypeName(currentName: String) -> String
    func generatePrivateAttributeName(currentName: String) -> String
    func generatePrivateFunctionName(currentName: String) -> String
}
