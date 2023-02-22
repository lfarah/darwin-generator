//
//  PasswordCharacterItem.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 22/02/23.
//

import SwiftUI

struct PasswordCharacterItem: View {
    let data: PasswordCharacter
    let isSelected: Bool
    let isHidden: Bool
    let action: (() -> Void)

    var body: some View {
        let text = data
        Button(text.value, action: action)
            .foregroundColor(Color(hex: 0xE96479))
            .font(.largeTitle)
            .fontWeight(.black)
            .minimumScaleFactor(0.01)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black, lineWidth: 5)
            )
            .background(isSelected ? Color(hex: 0xF5E9CF) : .white)
            .cornerRadius(8)
            .opacity(isHidden ? 0 : 1)
    }
}

struct PasswordCharacterItem_Previews: PreviewProvider {
    static var previews: some View {
        PasswordCharacterItem(data: PasswordCharacter.mock, isSelected: false, isHidden: false) {
            print("Tapped")
        }
    }
}
