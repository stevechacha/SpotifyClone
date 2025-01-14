//
//  PlaylistResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation


struct Playlist: Codable {
    let collaborative: Bool?
    let description: String?
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let href: String?
    let id: String?
    let images: [APIImage]?
    let name: String?
    let owner: Owner?
    let isPublic: Bool?
    let snapshotId: String?
    let tracks: Tracks?
    let type: String?
    let uri: String?

    enum CodingKeys: String, CodingKey {
        case collaborative
        case description
        case externalUrls = "external_urls"
        case followers
        case href
        case id
        case images
        case name
        case owner
        case isPublic = "public"
        case snapshotId = "snapshot_id"
        case tracks
        case type
        case uri
    }
}
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
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [PlaylistItemsResponse]?
}


// MARK: - PlayerListShowItem
struct PlaylistItemsResponse: Codable {
    let addedAt: String
    let addedBy: AddedBy?
    let isLocal: Bool?
    let track: Track?
    
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





