//
//  CategorysPlaylistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

// MARK: - Category Playlists Response
struct CategorysPlaylistsResponse: Codable {
    let playlists: Playlists
}

// MARK: - SpotifyShows
struct SpotifyBrowseCategories: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [SingleBrowseCategory]
}

// MARK: - ShowItem
struct SingleBrowseCategory: Codable {
    let href: String?
    let icons: [APIImage]?
    let id: String
    let name: String?
}


struct SpotifyCategory {
    let id: String
    let name: String
    let imageURL: String
}









