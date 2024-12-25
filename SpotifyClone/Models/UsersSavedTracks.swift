//
//  UsersSavedTracks.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


import Foundation



struct UsersSavedTracks: Codable {
    let href: String
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    let items: [ShowItem]
}