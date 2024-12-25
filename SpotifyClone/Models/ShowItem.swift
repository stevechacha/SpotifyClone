//
//  ShowItem.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

struct ShowItem: Codable {
    let addedAt: String
    let album: Album?

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case album
    }
}
