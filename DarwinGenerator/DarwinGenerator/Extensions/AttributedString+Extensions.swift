//
//  AttributedString+Extensions.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 23/02/23.
//

import Foundation

// Used for a ForEach item in SwiftUI
extension AttributedString: Identifiable {
    public var id: String {
        return self.characters.map { String($0) }.reduce("", +)
    }
}
