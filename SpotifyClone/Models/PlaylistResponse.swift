//
//  PlaylistResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation




//// Get Playlist
//curl --request GET \
//  --url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
// @GET(https://api.spotify.com/v1/playlists/player_list_id)
// response Playlist

// MARK: - Playlists
struct Playlists: Codable {
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
    let items: [PlaylistItem]
}

// MARK: - Playlist
struct PlaylistItem: Codable {
    let collaborative: Bool
    let description: String
    let externalUrls: ExternalURLs
    let followers: Followers
    let href: String
    let id: String
    let images: [APIImage]
    let name: String
    let owner: Owner
    let publicAccess: Bool
    let snapshotID: String
    let tracks: Tracks
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case collaborative, description
        case externalUrls = "external_urls"
        case followers, href, id, images, name, owner
        case publicAccess = "public"
        case snapshotID = "snapshot_id"
        case tracks, type, uri
    }
}



// MARK: - Owner
struct Owner: Codable {
    let externalUrls: ExternalURLs
    let followers: Followers
    let href: String
    let id: String
    let type: String
    let uri: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
        case displayName = "display_name"
    }
}



// MARK: - Added By
struct AddedBy: Codable {
    let externalUrls: ExternalURLs
    let followers: Followers
    let href: String
    let id: String
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers, href, id, type, uri
    }
}


