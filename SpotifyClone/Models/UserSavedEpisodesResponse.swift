//
//  UserSavedEpisodesResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import Foundation

struct UserSavedEpisodesResponse: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [SavedEpisode]?
}

struct SavedEpisode: Codable {
    let addedAt: String?
    let episode: Episode?
    
    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case episode
    }
}
