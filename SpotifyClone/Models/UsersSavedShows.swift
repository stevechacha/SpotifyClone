//
//  UsersSavedShows.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation


// MARK: - UsersSavedShows
struct UsersSavedShows: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [ShowItem]
}