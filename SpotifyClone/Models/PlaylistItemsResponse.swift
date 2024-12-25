//
//  PlaylistItemsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

struct PlaylistItemsResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [PlayerListShowItem]
}


// MARK: - PlayerListShowItem
struct PlayerListShowItem: Codable {
    let addedAt: String
    let addedBy: AddedBy
    let isLocal: Bool
    let track: Track
    
    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}


