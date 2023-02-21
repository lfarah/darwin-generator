//
//  InformationState.swift
//  DarwinGenerator
//
//  Created by Lucas Farah on 21/02/23.
//

import Foundation

enum InformationState<T> {
    case loading
    case loaded(data: T)
    case error(error: Error)
}
