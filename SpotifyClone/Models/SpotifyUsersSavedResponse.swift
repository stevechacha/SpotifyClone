//
//  SpotifyUsersSavedResponse.swift
//  SpotifyClone
//
//  Created by stephen chacha on 23/12/2024.
//


//Get User's Saved Albums
struct SpotifyUsersSavedResponse: Codable {
    let href: String
    let limit: Int
    let next: String
    let offset: Int
    let previous: String?
    let total: Int
    let items: [ShowItem]
}