//
//  Artist.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation


struct SpotifySearchResponse: Codable {
    let artists: ArtistsResponse
}

struct ArtistsResponse: Codable {
    let items: [Artist]
}

// MARK: - Artist
struct Artist: Codable {
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let genres: [String]?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
    let popularity: Int?
    let type: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, genres, href, id, images, name, popularity, type, uri
    }
}

//struct Artist: Codable {
//    let externalUrls: ExternalUrls
//    let href: String
//    let id: String
//    let name: String
//    let type: String
//    let uri: String
//
//    enum CodingKeys: String, CodingKey {
//        case externalUrls = "external_urls"
//        case href
//        case id
//        case name
//        case type
//        case uri
//    }
//}





