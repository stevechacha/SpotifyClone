//
//  PlaylistHeaderViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import Foundation

struct PlaylistHeaderViewModel {
    let playlistName: String?
    let ownerName: String?
    let description: String?
    let artUrl: URL?
    let playlistDuration: String?
    let ownerArtUrl: URL?
    let userId: String?
    
    init(
        playlistName: String?,
        artUrl: URL?,
        ownerName: String?,
        description: String?,
        playlistDuration: String?,
        ownerArtUrl: URL?,
        userId: String?
    ) {
        self.playlistName = playlistName
        self.artUrl = artUrl
        self.ownerName = ownerName
        self.description = description
        self.playlistDuration = playlistDuration
        self.ownerArtUrl = ownerArtUrl
        self.userId = userId
    }
}




