//
//  AddPlaylistCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 14/01/2025.
//

import Foundation

struct AddPlaylistCellViewModel {
    let trackName: String
    let trackArtist: String
    let trackArtUrl : URL?
    
    init(trackName: String, trackArtist: String, trackArtUrl: URL?) {
        self.trackName = trackName
        self.trackArtist = trackArtist
        self.trackArtUrl = trackArtUrl
    }
    
}


