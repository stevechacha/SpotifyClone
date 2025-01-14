//
//  PlaylistViewModelCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import Foundation


struct PlaylistViewModelCell {
    let name: String
    let artUrl: URL?
  
    init(name: String, artUrl: URL?) {
        self.name = name
        self.artUrl = artUrl
    }
}

