//
//  FeaturedPlayList.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation


struct FeaturedPlayListResponse: Codable {
    let message: String?
    let playlists: Playlists?
}
