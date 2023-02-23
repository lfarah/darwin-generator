//
//  BookService.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

struct BookService {
    func fetchBookText() async throws -> String {

        // TODO: Move hardcoded URL to another place
        guard let url = URL(string: "https://www.gutenberg.org/cache/epub/1228/pg1228.txt") else {
            throw NetworkError.invalidURL
        }

        let data = try await URLSession.shared.data(from: url).0

        guard let result = String(data: data, encoding: .utf8) else {
            throw NetworkError.empty
        }
        return result
    }
}
