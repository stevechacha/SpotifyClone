//
//  SearchResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 27/12/2024.
//

import Foundation

// MARK: - SearchResponse
struct SearchResponses: Codable {
    let shows: SearchItemsResponse<Show>?
    let episodes: SearchItemsResponse<Episode>?
    let chapters: SearchItemsResponse<Chapter>?
    let tracks: SearchItemsResponse<Track>?
    let artists: SearchItemsResponse<Artist>?
    let albums: SearchItemsResponse<Album>?
    let playlists: SearchItemsResponse<PlaylistItem>?
    let audiobooks: SearchItemsResponse<Audiobook>?
}

// MARK: - SearchItemsResponse
struct SearchItemsResponse<T: Codable>: Codable {
    let items: [T]
}


struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
}


struct AlbumsSearchResultsResponse: Codable {
    let items: [Album]
}


// MARK: - ShowSearchResults
struct ShowSearchResults: Codable {
    let items: [Show]?
}

// MARK: - EpisodeSearchResults
struct EpisodeSearchResults: Codable {
    let items: [Episode]
}

// MARK: - ChapterSearchResults
struct ChapterSearchResults: Codable {
    let items: [Chapter]
}
