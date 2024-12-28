//
//  SpotifyUsersAlbumSavedResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 27/12/2024.
//


import Foundation

//Get User's Saved Albums
struct SpotifyUsersAlbumSavedResponse: Codable {
    let href: String?
    let items: [SpotifyUsersAlbumSavedItemResponse]
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
}



struct SpotifyUsersAlbumSavedItemResponse: Codable {
    let addedAt: String
    let album: Album?  // Marked as optional

    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case album
    }
}









