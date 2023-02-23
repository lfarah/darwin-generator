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
        Button(action: action, label: {
            Text(text.value)
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .layoutPriority(1)
                .foregroundColor(Color(hex: 0xE96479))
                .font(.largeTitle)
                .fontWeight(.black)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black, lineWidth: 5)
                )
                .background(isSelected ? .white : Color(hex: 0xF5E9CF))
                .cornerRadius(8)
                .opacity(isHidden ? 0 : 1)
        })
    }
}

struct PasswordCharacterItem_Previews: PreviewProvider {
    static var previews: some View {
        PasswordCharacterItem(data: PasswordCharacter.mock, isSelected: false, isHidden: false) {
            print("Tapped")
        }
    }
}
