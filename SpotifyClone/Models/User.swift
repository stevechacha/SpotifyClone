//
//  User.swift
//  SpotifyClone
//
//  Created by stephen chacha on 05/12/2024.
//

import Foundation

struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
