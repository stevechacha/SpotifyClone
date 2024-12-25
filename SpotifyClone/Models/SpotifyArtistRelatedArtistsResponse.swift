//
//  SpotifyArtistRelatedArtistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation

struct SpotifyArtistRelatedArtistsResponse : Codable {
    let externalUrls : ExternalUrls
    let followers : Followers
    let genres: [String]
    let href : String
    let id: String
    let image: APIImage
    let name: String
    let popularity: Int
    let type: Artist
    let uri: String
}



