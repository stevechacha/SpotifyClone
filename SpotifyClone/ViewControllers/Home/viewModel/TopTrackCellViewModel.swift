//
//  TopTrackCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/01/2025.
//

import Foundation

struct TopTrackCellViewModel {
    let name: String
    let artUrl: URL?
    

    // Initializer
    init(name: String, artUrl: URL?) {
        self.name = name
        self.artUrl = artUrl
    }
}

