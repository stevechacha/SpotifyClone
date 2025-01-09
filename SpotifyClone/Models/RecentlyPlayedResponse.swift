//
//  RecentlyPlayedResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/01/2025.
//

import Foundation

struct RecentlyPlayedResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let cursors: Cursors
    let total: Int?
    let items: [RecentlyPlayedItem]
}


struct RecentlyPlayedItem: Codable {
    let track: Track?
    let playedAt: String
    let context: PlayContext?
    
    enum CodingKeys: String, CodingKey {
        case track
        case playedAt = "played_at"
        case context
    }
}

struct PlayContext: Codable {
    let type: String
    let uri: String
}

struct Cursors: Codable {
    let after: String?
    let before: String?
}

