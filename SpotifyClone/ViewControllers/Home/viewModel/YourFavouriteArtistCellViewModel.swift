//
//  FollowedArtistAlbumCellViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/01/2025.
//

import Foundation
struct YourFavouriteArtistCellViewModel {
    let name: String
    let artUrl: URL?
    let numberOfTracks: Int
    let artistName: String
    
    // Computed property to format the number of tracks
    var tracksText: String {
        return "\(numberOfTracks) \(numberOfTracks == 1 ? "track" : "tracks")"
    }
    
    // Initializer
    init(name: String, artUrl: URL?, numberOfTracks: Int, artistName: String) {
        self.name = name
        self.artUrl = artUrl
        self.numberOfTracks = numberOfTracks
        self.artistName = artistName
    }
}
