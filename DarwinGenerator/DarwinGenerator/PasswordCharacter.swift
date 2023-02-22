//
//  PasswordCharacter.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

struct PasswordCharacter: Identifiable, Equatable {
    var id: String = UUID().uuidString
    let value: String
    let index: String.Index
    let sentence: String
}

extension PasswordCharacter {
    static var mock: PasswordCharacter {
        return PasswordCharacter(value: "b", index: String.Index.init(utf16Offset: 0, in: ""), sentence: "abc")
    }
}
