//
//  PasswordCharacter.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

struct PasswordCharacter: Identifiable {
    var id: String = UUID().uuidString
    let value: String
    let index: String.Index
    let sentence: String
}
