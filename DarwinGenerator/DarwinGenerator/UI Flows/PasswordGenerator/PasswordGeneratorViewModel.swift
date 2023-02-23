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

    @Published var isNumberAllowed = false
    @Published var isSymbolAllowed = false

    @Published var characterCount: Double = 5
    
    let characterCountRange: ClosedRange<Double> = 2...7
    let minimumValueText = "2"
    let maximumValueText = "7"
    
    var fullText = ""
    private var infoUpdateCancellable: AnyCancellable?

    
    init() {
        bind()
    }
    
    func bind() {
        // As soon as a user changes one of configuration options (length, numbers, symbols), the password should generate
        infoUpdateCancellable = Publishers
            .CombineLatest3($isNumberAllowed, $isSymbolAllowed, $characterCount)
            .removeDuplicates(by: { lhs, rhs in
                lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2
            })
            .sink(receiveValue: { value in
                Task {
                    await self.reloadData()
                }
            })
    }
    
    func reloadData() async {
        state = .loading
        let service = BookService()
        
        // I would've done this in the repository + Caching layers if I had more time.
        if !fullText.isEmpty {
            let generatedPassword = generatePassword(with: fullText, characterCount: characterCount)
            state = .loaded(data: generatedPassword)
        } else {
            do {
                let data = try await service.fetchBookText()
                let generatedPassword = generatePassword(with: data, characterCount: characterCount)
                fullText = data
                state = .loaded(data: generatedPassword)
            } catch let error {
                state = .error(error: error)
            }
        }
    }
    
    // Parsing information to show the sentence this character was picked from, having only that character in red
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
    func generatePassword(with data: String, characterCount: Double) -> [PasswordCharacter] {
        var finalPassword: [PasswordCharacter] = []

        // 1. Pick 10 random sentences
        let randomSentences = data.components(separatedBy: ".")
        let finalRandomSentences = (0...200).compactMap { _ in
            randomSentences.randomElement()
        }
        
        // 2. Mingles them together
        let parsedRandomSentences: [(Character, DefaultIndices<String>.Element, String)] = finalRandomSentences.map { sentence in
            return sentence.indices.compactMap { index in
                let character = sentence[index]
                
                // If is number allowed, continue. if not, skip if contains a number
                guard isNumberAllowed || character.isNumber == false else {
                    return nil
                }
                
                // If is symbol allowed, continue. if not, skip if contains a symbol
                guard isSymbolAllowed || character.containsSymbol == false else {
                    return nil
                }

                
                return (character, index, sentence)
            }
        }
            .reduce([], +)
            .filter { $0.0 != " " }
            .shuffled()
        
        // 3. Picks random characters
        
        // Characters in this for loop can be either letters, numbers or symbols. This way, we ensure that there's a possibility of having multiple numbers or symbols
        let parsedCharacterCount = Int(characterCount)
        for _ in 0 ..< parsedCharacterCount {
            if let randomCharacter = parsedRandomSentences.randomElement() {
                finalPassword.append(PasswordCharacter(value: String(randomCharacter.0), index: randomCharacter.1, sentence: randomCharacter.2))
            }
        }
        
        let containsNumbers = finalPassword.filter { $0.value.first?.isNumber ?? false }.count > 0

        // If the password requires a number and we didn't find one, replace a current character with a random number from the book. This password will now have 1 number.
        if !containsNumbers && isNumberAllowed {
            let onlyNumbers = parsedRandomSentences.filter({ $0.0.isNumber })
            if let randomNumber = onlyNumbers.randomElement() {
                finalPassword[finalPassword.count - 2] = PasswordCharacter(value: String(randomNumber.0), index: randomNumber.1, sentence: randomNumber.2)
            }
        }
        
        let containsSymbol = finalPassword.filter { $0.value.first?.containsSymbol ?? false }.count > 0
        
        // If the password requires a symbol and we didn't find one, replace a current character with a random symbol from the book. This password will now have 1 symbol.
        if !containsSymbol && isSymbolAllowed {
            let onlySymbols = parsedRandomSentences.filter({ $0.0.containsSymbol && $0.0 != "°" && $0.0 != "\r\n" })
            if let randomSymbol = onlySymbols.randomElement() {
                finalPassword[finalPassword.count - 1] = PasswordCharacter(value: String(randomSymbol.0), index: randomSymbol.1, sentence: randomSymbol.2)

            }
        }
        
        // 4. Mixes that into a password.
        // Shuffling finalPassword again so we don't have numbers and symbols aren't usually in the last two position
        return finalPassword.shuffled()
    }
}
