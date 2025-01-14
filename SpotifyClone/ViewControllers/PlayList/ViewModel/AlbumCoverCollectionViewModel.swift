//
//  AlbumCoverCollectionViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import Foundation

struct AlbumCoverCollectionViewModel {
    let playlistName: String?
    let ownerName: String?
    let description: String?
    let artUrl: URL?
    let duration: String?
    
    init(playlistName: String, artUrl: URL?, ownerName: String, description: String, duration: String) {
        self.playlistName = playlistName
        self.artUrl = artUrl
        self.ownerName = ownerName
        self.duration = duration
        self.description = description
    }
}
