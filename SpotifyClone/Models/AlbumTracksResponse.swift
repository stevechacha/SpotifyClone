//
//  AlbumTracksResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import Foundation

struct SpotifyAlbumsSearchResponse: Codable {
    let album: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}

struct AlbumTracksResponse: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [Track]
}
