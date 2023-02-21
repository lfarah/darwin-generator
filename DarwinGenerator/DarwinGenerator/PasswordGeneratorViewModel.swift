//
//  PasswordGeneratorViewModel.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

@MainActor
class PasswordGeneratorViewModel: ObservableObject {
    @Published var state: InformationState<String> = .loading
    
    var characterCount = 5
    
    func fetchNetwork() async {
        let service = BookService()
        do {
            let data = try await service.fetchBookText()
            let generatedPassword = generatePassword(with: data, characterCount: characterCount)
            state = .loaded(data: generatedPassword)
        } catch let error {
            state = .error(error: error)
        }
    }
    
    /// Parses book data into password
    func generatePassword(with data: String, characterCount: Int) -> String {
        var finalPassword = ""
        for _ in 0...characterCount {
            // No spaces
            // Only special characters when needed
            if let randomCharacter = data.replacingOccurrences(of: " ", with: "").randomElement() {
                finalPassword += String(randomCharacter)
            }
        }
        return finalPassword
    }
}
