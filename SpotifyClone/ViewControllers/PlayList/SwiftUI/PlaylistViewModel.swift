//
//  PlaylistViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//


import SwiftUI
import Combine

class PlaylistViewModel: ObservableObject {
    @Published var userPlaylists: CurrentUsersPlaylistsResponse?
    @Published var selectedPlaylist: SpotifyPlaylist?
    @Published var playlistTracks: PlaylistTracksResponse?
    @Published var playlistCoverImage: [APIImage]?
    @Published var errorMessage: String?
    @Published var playlist: PlaylistItem?


    func fetchUserPlaylists() {
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    print(playlists)
                    self?.userPlaylists = playlists
                case .failure(let error):
                    self?.errorMessage = "Failed to load user playlists: \(error)"
                }
            }
        }
    }
    
 
    
    func fetchPlaylistDetails(playlistID: String) {
        PlaylistApiCaller.shared.getPlaylistDetails(playlistID: playlistID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlist):
                    self?.selectedPlaylist = playlist
                case .failure(let error):
                    self?.errorMessage = "Failed to load playlist details: \(error)"
                }
            }
        }
    }
    
    func fetchPlaylistTracks(playlistID: String) {
        PlaylistApiCaller.shared.getPlaylistTracks(playlistID: playlistID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.playlistTracks = tracks
                case .failure(let error):
                    self?.errorMessage = "Failed to load playlist tracks: \(error)"
                }
            }
        }
    }
    
    func fetchPlaylistCoverImage(playlistID: String) {
        PlaylistApiCaller.shared.getPlaylistCoverImage(playlistID: playlistID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let images):
                    self?.playlistCoverImage = images
                case .failure(let error):
                    self?.errorMessage = "Failed to load playlist cover image: \(error)"
                }
            }
        }
    }
    
    
}
