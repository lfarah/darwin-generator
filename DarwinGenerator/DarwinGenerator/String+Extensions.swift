//
//  String+Extensions.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 23/02/23.
//

import Foundation

extension Character {
    var containsSymbol: Bool {
        return String(self).range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
    }
}
