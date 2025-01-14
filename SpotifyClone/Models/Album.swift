//
//  Album.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation

struct Albums: Codable {
    let items: [Album]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
}

////Get Album
struct Album: Codable  {
    let albumType: String?
    let totalTracks: Int?
    let availableMarkets: [String]?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
    let releaseDate: String?
    let releaseDatePrecision: String?
    let restrictions: Restrictions?
    let type: String?
    let uri: String?
    let artists: [Artist]?
    let tracks: Tracks?
    let copyrights: [Copyright]?
    let externalIds: ExternalIDs?
    let genres: [String]?
    let label: String?
    let popularity: Int?

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case totalTracks = "total_tracks"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case restrictions, type, uri, artists, tracks, copyrights
        case externalIds = "external_ids"
        case genres, label, popularity
    }
}

//struct Album: Codable {
//    let albumType: String
//    let totalTracks: Int
//    let availableMarkets: [String]
//    let externalUrls: ExternalUrls
//    let href: String
//    let id: String
//    let images: [Image]
//    let name: String
//    let releaseDate: String
//    let releaseDatePrecision: String
//    let restrictions: Restrictions?
//    let type: String
//    let uri: String
//    let artists: [Artist]
//
//    enum CodingKeys: String, CodingKey {
//        case albumType = "album_type"
//        case totalTracks = "total_tracks"
//        case availableMarkets = "available_markets"
//        case externalUrls = "external_urls"
//        case href
//        case id
//        case images
//        case name
//        case releaseDate = "release_date"
//        case releaseDatePrecision = "release_date_precision"
//        case restrictions
//        case type
//        case uri
//        case artists
//    }
//}








