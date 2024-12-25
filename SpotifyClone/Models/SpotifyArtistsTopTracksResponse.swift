//
//  SpotifyArtistsTopTracksResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


//
//Artist's Top Tracks
struct SpotifyArtistsTopTracksResponse: Codable {
    let tracks: [Track]
}


struct ExternalIds: Codable {
    let isrc: String?
    let ean: String?
    let upc: String?
}
