//
//  CategorysPlaylistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

import Foundation
// Get Category's Playlists
//curl --request GET \
//  --url https://api.spotify.com/v1/browse/categories/dinner/playlists \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'

// @GET(https://api.spotify.com/v1/browse/categories/{category_id}/playlists

// MARK: - PopularPlaylistsResponse
struct CategorysPlaylistsResponse: Codable {
    let message: String
    let playlists: Playlists
}
