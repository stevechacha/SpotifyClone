//
//  PlaylistResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation


// MARK: - Playlists
struct Playlists: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [PlaylistItem]?
}

struct PlaylistTracksResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int?
    let items: [PlaylistItemsResponse]
}


// MARK: - PlayerListShowItem
struct PlaylistItemsResponse: Codable {
    let addedAt: String
    let addedBy: AddedBy?
    let isLocal: Bool?
    let track: Track
    
    enum CodingKeys: String, CodingKey {
        case addedAt = "added_at"
        case addedBy = "added_by"
        case isLocal = "is_local"
        case track
    }
}



// MARK: - Playlist
struct PlaylistItem: Codable , Identifiable {
    let collaborative: Bool?
    let description: String?
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
    let owner: Owner?
    let publicAccess: Bool?
    let snapshotID: String?
    let tracks: Tracks?
    let type: String?
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case collaborative, description
        case externalUrls = "external_urls"
        case followers, href, id, images, name, owner
        case publicAccess = "public"
        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}

//// MARK: - Playlist
//struct PlaylistItems: Codable {
//    let collaborative: Bool
//    let description: String
//    let externalURLs: ExternalURLs
//    let href: String
//    let id: String
//    let images: [APIImage]
//    let name: String
//    let owner: PlaylistOwner
//    let publicAccess: Bool?
//    let snapshotID: String
//    let tracks: Tracks
//    let type: String
//    let uri: String
//
//    enum CodingKeys: String, CodingKey {
//        case collaborative, description
//        case externalURLs = "external_urls"
//        case href, id, images, name, owner
//        case publicAccess = "public"
//        case snapshotID = "snapshot_id"
//        case tracks, type, uri
//    }
//}



// MARK: - Owner
struct Owner: Codable {
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String
    let id: String
    let type: String
    let uri: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
        case displayName = "display_name"
    }
}



// MARK: - Added By
struct AddedBy: Codable {
    let externalUrls: ExternalURLs?
    let followers: Followers?
    let href: String
    let id: String
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
    }
}


