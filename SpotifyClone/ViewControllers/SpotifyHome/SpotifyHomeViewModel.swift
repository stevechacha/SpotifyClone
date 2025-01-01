//
//  SpotifyHomeViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//


import SwiftUI
import Combine

// MARK: - ViewModel
class SpotifyHomeViewModel: ObservableObject {
    
    @Published var playlists: [PlaylistItem] = []
    @Published var podcasts: [UsersSavedShowsItems] = []
    @Published var albums: [String] = []
    @Published var pickedForYou: [PlaylistItem] = []
    @Published var jumpBackIn: [Artist] = []
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let apiManager = AuthManager.shared


    init() {
        fetchPodcasts()
        fetchUserSavedAlbums()
    }



    private func fetchPodcasts() {
        ChapterApiCaller.shared.getUserSavedPodCasts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.podcasts = response.items ?? []
                case .failure(let error):
                    print("Failed to fetch podcasts: \(error)")
                }
            }
        }
    }

    private func fetchUserSavedAlbums() {
        AlbumApiCaller.shared.getSavedAlbums { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.albums = response.items.map { $0.album?.name ?? "" }
                case .failure(let error):
                    print("Failed to fetch user-saved albums: \(error)")
                }
            }
        }
    }
    
    func fetchPlaylistss() {
        isLoading = true
        apiManager.performRequest(
            url: URL(string: "https://api.spotify.com/v1/me/playlists"),
            type: .GET,
            responseType: SpotifyPlaylistsResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.playlists = response.items
                case .failure(let error):
                    print("Error fetching playlists: \(error)")
                }
            }
        }
    }

    func fetchPickedForYou() {
        isLoading = true
        // Replace with the actual endpoint or logic for fetching "Picked for You"
        apiManager.performRequest(
            url: URL(string: "https://api.spotify.com/v1/browse/featured-playlists"),
            type: .GET,
            responseType: SpotifyPlaylistsResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.pickedForYou = response.items
                case .failure(let error):
                    print("Error fetching picked for you: \(error)")
                }
            }
        }
    }

    func fetchJumpBackIn() {
        isLoading = true
        // Replace with the actual endpoint or logic for fetching "Jump Back In"
        apiManager.performRequest(
            url: URL(string: "https://api.spotify.com/v1/me/top/artists"),
            type: .GET,
            responseType: SpotifyArtistsResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.jumpBackIn = response.artists
                case .failure(let error):
                    print("Error fetching jump back in: \(error)")
                }
            }
        }
    }
}

struct Playlist: Identifiable, Decodable {
    let id: String
    let name: String
    let description: String?
}

struct SpotifyPlaylistsResponse: Decodable {
    let items: [PlaylistItem]
}
