//
//  TopArtistCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/01/2025.
//

import Foundation

struct TopArtistCellViewModel {
    let name: String
    let type: String
    let imageUrl: URL?

    
    // Computed property to format the number of tracks
//    var tracksText: String {
//        return "\(numberOfTracks) \(numberOfTracks == 1 ? "track" : "tracks")"
//    }
//    
    // Initializer
    init(name: String, type: String ,imageUrl: URL?) {
        self.name = name
        self.type = type
        self.imageUrl = imageUrl
    }
}

