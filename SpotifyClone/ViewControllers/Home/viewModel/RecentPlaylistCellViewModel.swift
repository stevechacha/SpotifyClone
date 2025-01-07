//
//  RecentPlaylistCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/01/2025.
//

import Foundation

struct RecentPlaylistCellViewModel {
    let name: String
    let artUrl: URL?
    let numberOfTracks: Int
    let artistName: String
    let objectType: String // e.g., "artist", "playlist", "album", "show"
    
    var tracksText: String {
        return "\(numberOfTracks) \(numberOfTracks == 1 ? "track" : "tracks")"
    }
    
    init(name: String, artUrl: URL?, numberOfTracks: Int, artistName: String, objectType: String) {
        self.name = name
        self.artUrl = artUrl
        self.numberOfTracks = numberOfTracks
        self.artistName = artistName
        self.objectType = objectType
    }
}


