//
//  SpotifyAlbumResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

//Get Several Albums
struct SpotifyAlbumResponse: Codable {
    let albums: [SpotifyAlbum]?
}




struct SpotifyAlbum: Codable {
    let album_type: String?
    let total_tracks: Int?
    let available_markets: [String]?
    let external_urls: ExternalURLs?
    let href: String
    let id: String
    let images: [APIImage]
    let name: String
    let release_date: String?
    let release_date_precision: String?
    let restrictions: Restrictions?
    let type: String
    let uri: String
    let artists: [SpotifyArtist]?
    let tracks: Tracks?
    let copyrights: [Copyright]
    let external_ids: ExternalIDs
    let genres: [String]
    let label: String
    let popularity: Int
    
    
}

struct SpotifyArtist: Codable {
    let external_urls: ExternalURLs?
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String
}
