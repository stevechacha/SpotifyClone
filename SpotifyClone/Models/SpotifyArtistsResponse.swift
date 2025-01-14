//
//  SpotifyArtistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

//Get Several Artists
struct SpotifyArtistsResponse: Codable  {
    let artists: [Artist]
}


struct SpotifyArtistsDetailResponse: Codable {
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let genres: [String]?
    let href: String
    let id: String
    let images: [APIImage]?  // Changed from 'image' to 'images' and made it an array
    let name: String
    let popularity: Int
    let type: String         // Changed from 'Artist?' to 'String'
    let uri: String
    let bio: String? // New field for description

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case type
        case uri
        case bio
    }
}

