//
//  PasswordGeneratorViewModel.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation
import Combine
import UIKit

@MainActor
class PasswordGeneratorViewModel: ObservableObject {
    @Published var state: InformationState<[PasswordCharacter]> = .loading
    @Published var selectedCharacterText: AttributedString?
    @Published var selectedCharacter: PasswordCharacter?
    @Published var selectedCharacterIndex: Int?

    var characterCount = 5
    
    var fullText = ""
    private var cancellable: AnyCancellable?

    
    init() {
        bind()
    }
    
    func bind() {
//        $selectedCharacter
//            .removeDuplicates()
//            .map { character in
//
//            let text = "On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through"
//
//            let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ]
//            let myAttrString = NSAttributedString(string: text, attributes: myAttribute)
//
//            return text.map {
//                let finalCharacterStr = String($0)
//                if finalCharacterStr == character {
//                    return (finalCharacterStr, UIColor.red)
//                } else {
//                    return (finalCharacterStr, UIColor.black)
//                }
//            }
//        }
////        .eraseToAnyPublisher()
//        .assign(to: &$selectedCharacterText)
    }
    
    func fetchNetwork() async {
        let service = BookService()
        do {
            let data = try await service.fetchBookText()
            let generatedPassword = generatePassword(with: data, characterCount: characterCount)
            fullText = data
            state = .loaded(data: generatedPassword)
        } catch let error {
            state = .error(error: error)
        }
    }
    
    func selectedCharacter(text: PasswordCharacter, at index: Int) {
        guard text != selectedCharacter else {
            selectedCharacter = nil
            selectedCharacterText = nil
            selectedCharacterIndex = nil
            return
        }
        selectedCharacterIndex = index
        selectedCharacter = text
        let parsedText = text.sentence
        
        let attributtedStringArr = parsedText.indices.map { index in
            let character = String(parsedText[index])
            
            let distance = fullText.distance(from: parsedText.startIndex, to: index)
            let distance2 = fullText.distance(from: parsedText.startIndex, to: text.index)
            if distance == distance2 {
                var attributtedString = AttributedString(stringLiteral: character)
                attributtedString.foregroundColor = .red
                return attributtedString
            } else {
                var attributtedString = AttributedString(stringLiteral: character)
                attributtedString.foregroundColor = .black
                return attributtedString
            }
        }
         selectedCharacterText = attributtedStringArr[1...].reduce(attributtedStringArr[0], +)
    }
    
    /// Parses book data into password
    /// Build a script that picks random words (or sentences) from the book, mingles them together, picks random characters and mixes that into a password.
    ///
    ///
    ///
    
    func generatePassword(with data: String, characterCount: Int) -> [PasswordCharacter] {
        var finalPassword: [PasswordCharacter] = []

        // 1. Pick 10 random sentences
        let randomSentences = data.components(separatedBy: ".")
        let finalRandomSentences = (0...1000).compactMap { _ in
            randomSentences.randomElement()
        }
        
        // 2. Mingles them together
        let parsedRandomSentences: [(Character, DefaultIndices<String>.Element, String)] = finalRandomSentences.map { sentence in
            return sentence.indices.map { index in
                let character = sentence[index]
                return (character, index, sentence)
            }
        }
            .reduce([], +)
            .filter { $0.0 != " " }
            .shuffled()
        
        
        for _ in 0...characterCount {
            if let randomCharacter = parsedRandomSentences.randomElement() {
                finalPassword.append(PasswordCharacter(value: String(randomCharacter.0), index: randomCharacter.1, sentence: randomCharacter.2))
            }
        }
        
        let containsNumbers = finalPassword.filter { $0.value.first?.isNumber ?? false }.count > 0
        let containsSymbol = finalPassword.filter { character in
            guard let value = character.value.first else {
                return false
            }
            return String(value).range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        }.count > 0

        if !containsNumbers {
            let onlyNumbers = parsedRandomSentences.filter({ $0.0.isNumber })
            if let randomNumber = onlyNumbers.randomElement() {
                finalPassword[finalPassword.count - 2] = PasswordCharacter(value: String(randomNumber.0), index: randomNumber.1, sentence: randomNumber.2)
            }
        }
        
        if !containsSymbol {
            let onlySymbols = parsedRandomSentences.filter({ String($0.0).range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil && $0.0 != "°" && $0.0 != "\r\n" })
            if let randomSymbol = onlySymbols.randomElement() {
                finalPassword[finalPassword.count - 1] = PasswordCharacter(value: String(randomSymbol.0), index: randomSymbol.1, sentence: randomSymbol.2)

            }
        }
        
        print("finalPassword: \(finalPassword)")

        return finalPassword.shuffled()
    }
}
