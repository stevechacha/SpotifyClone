//
//  GenreSeedsResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 30/12/2024.
//

import Foundation
// Response model for available genres
struct GenreSeedsResponse: Decodable {
    let genres: [String]
}
