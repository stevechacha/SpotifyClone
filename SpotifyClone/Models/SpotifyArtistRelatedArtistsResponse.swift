//
//  SpotifyArtistRelatedArtistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

struct SpotifyArtistRelatedArtistsResponse: Codable {
    let artists: [RelatedArtist]?
}

struct RelatedArtist: Codable {
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let genres: [String]?
    let href: String
    let id: String
    let images: [APIImage]?
    let name: String
    let popularity: Int?
    let type: String
    let uri: String
}




