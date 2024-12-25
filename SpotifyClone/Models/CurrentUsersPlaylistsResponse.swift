//
//  CurrentUsersPlaylistsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//

//Get Current User's Playlists
//curl --request GET \
//  --url https://api.spotify.com/v1/me/playlists \
//  --header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z'
// @GET(/me/playlists)

// MARK: - CurrentUsersPlaylistsResponse
struct CurrentUsersPlaylistsResponse: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [PlaylistItem]
}






