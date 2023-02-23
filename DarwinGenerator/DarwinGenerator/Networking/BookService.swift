//
//  BookService.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

struct BookService {
    func fetchBookText() async throws -> String {
        guard let url = URL(string: Keys.baseURL) else {
            throw NetworkError.invalidURL
        }

        let data = try await URLSession.shared.data(from: url).0

        guard let result = String(data: data, encoding: .utf8) else {
            throw NetworkError.empty
        }
        return result
    }
}
