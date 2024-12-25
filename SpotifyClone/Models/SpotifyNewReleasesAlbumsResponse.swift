//
//  SpotifyNewReleasesAlbumsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


//Get New Releases
struct SpotifyNewReleasesAlbumsResponse: Codable {
    let href: String
    let limit: Int
    let next: String
    let offset: Int
    let previous: String?
    let total: Int
    let items: [Album]
}

struct NewReleasesResponse : Codable {
    let albums: AlbumsResponse
}

struct AlbumsResponse : Codable {
    let items: [Album]
}
