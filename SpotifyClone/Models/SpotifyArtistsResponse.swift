//
//  SpotifyArtistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

//Get Several Artists
struct SpotifyArtistsResponse: Codable {
    let artists: [Artist]
}


struct Followers: Codable {
    let href: String?
    let total: Int
}

struct SpotifyArtistsDetailResponse : Codable {
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

