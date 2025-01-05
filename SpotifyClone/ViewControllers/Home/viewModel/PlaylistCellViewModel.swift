//
//  PlaylistCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/01/2025.
//

import Foundation


struct PlaylistCellViewModel {
    let name: String
    let artUrl: URL?
    
//    // Computed property to format the number of tracks
//    var tracksText: String {
//        return "\(numberOfTracks) \(numberOfTracks == 1 ? "track" : "tracks")"
//    }
//    
    // Initializer
    init(name: String, artUrl: URL?) {
        self.name = name
        self.artUrl = artUrl
    }
}

