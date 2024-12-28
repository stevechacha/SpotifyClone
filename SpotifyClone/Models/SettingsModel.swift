//
//  SettingsModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 24/12/2024.
//
import Foundation

struct SettingsModel {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handle: () -> Void
}
