//
//  Seed.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation

// MARK: - Seed
struct Seed: Codable {
    let afterFilteringSize: Int
    let afterRelinkingSize: Int
    let href: String?
    let id: String
    let initialPoolSize: Int
    let type: String
}
