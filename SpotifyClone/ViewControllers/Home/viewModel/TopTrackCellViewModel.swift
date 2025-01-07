//
//  TopTrackCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/01/2025.
//

import Foundation

struct TopTrackCellViewModel {
    let id: String // Track ID
    let name: String
    var artUrl: URL? // Mutable to allow updates

    // Initializer
    init(id: String, name: String, artUrl: URL?) {
        self.id = id
        self.name = name
        self.artUrl = artUrl
    }
}

