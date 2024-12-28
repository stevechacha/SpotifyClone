//
//  Tracks.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation

struct Tracks: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [Track]?  // Optional, since it might be missing or empty

    enum CodingKeys: String, CodingKey {
        case href
        case limit
        case next
        case offset
        case previous
        case total
        case items
    }
}



struct Track: Codable {
    let artists: [Artist]?
    let album: Album?
    let availableMarkets: [String]?
    let discNumber: Int?
    let durationMs: Int?
    let explicit: Bool?
    let externalUrls: ExternalUrls?
    let externalIds: ExternalIds?
    let href: String?
    let id: String
    let isPlayable: Bool?
    let linkedFrom: LinkedFrom?
    let restrictions: Restrictions?
    let name: String
    let popularity: Int?
    let previewUrl: String?
    let trackNumber: Int
    let type: String?
    let uri: String?
    let isLocal: Bool?

    enum CodingKeys: String, CodingKey {
        case artists, album
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMs = "duration_ms"
        case explicit
        case externalIds = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isPlayable = "is_playable"
        case linkedFrom = "linked_from"
        case restrictions, name,popularity
        case previewUrl = "preview_url"
        case trackNumber = "track_number"
        case type, uri
        case isLocal = "is_local"
    }
    
    
}



//
////curl --request GET \
////  --url https://api.spotify.com/v1/tracks/11dFghVXANMlKmJXsNCbNl \
////  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
////Get Track
////@GET(/tracks/{id})
//// MARK: - Track
//struct Track: Codable {
//    let discNumber: Int
//    let durationMs: Int
//    let explicit: Bool
//    let externalIds: ExternalIds
//    let externalUrls: ExternalURLs
//    let href: String
//    let id: String
//    let isPlayable: Bool
//    let linkedFrom: [String: String]
//    let restrictions: Restrictions
//    let name: String?
//    let popularity: Int
//    let previewUrl: String
//    let trackNumber: Int
//    let type: String
//    let uri: String
//    let isLocal: Bool
//    
//    enum CodingKeys: String, CodingKey {
//        case album, artists
//        case availableMarkets = "available_markets"
//        case discNumber = "disc_number"
//        case durationMs = "duration_ms"
//        case explicit
//        case externalIds = "external_ids"
//        case externalUrls = "external_urls"
//        case href, id
//        case isPlayable = "is_playable"
//        case linkedFrom = "linked_from"
//        case restrictions, name, popularity
//        case previewUrl = "preview_url"
//        case trackNumber = "track_number"
//        case type, uri
//        case isLocal = "is_local"
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        // Use decodeIfPresent to handle missing 'available_markets' gracefully
//        self.availableMarkets = try container.decodeIfPresent([String].self, forKey: .availableMarkets) ?? []  // Default to empty array if missing
//        
//        // Decode other properties as usual
//        self.album = try container.decode(Album.self, forKey: .album)
//        self.artists = try container.decode([Artist].self, forKey: .artists)
//        self.discNumber = try container.decode(Int.self, forKey: .discNumber)
//        self.durationMs = try container.decode(Int.self, forKey: .durationMs)
//        self.explicit = try container.decode(Bool.self, forKey: .explicit)
//        self.externalIds = try container.decode(ExternalIds.self, forKey: .externalIds)
//        self.externalUrls = try container.decode(ExternalURLs.self, forKey: .externalUrls)
//        self.href = try container.decode(String.self, forKey: .href)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.isPlayable = try container.decode(Bool.self, forKey: .isPlayable)
//        self.linkedFrom = try container.decode([String: String].self, forKey: .linkedFrom)
//        self.restrictions = try container.decode(Restrictions.self, forKey: .restrictions)
//        self.name = try container.decodeIfPresent(String.self, forKey: .name)
//        self.popularity = try container.decode(Int.self, forKey: .popularity)
//        self.previewUrl = try container.decode(String.self, forKey: .previewUrl)
//        self.trackNumber = try container.decode(Int.self, forKey: .trackNumber)
//        self.type = try container.decode(String.self, forKey: .type)
//        self.uri = try container.decode(String.self, forKey: .uri)
//        self.isLocal = try container.decode(Bool.self, forKey: .isLocal)
//    }
//    
//    
//}
