//
//  HomeViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//


import Foundation

final class HomeViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var topTracks: [TopItem] = []
    @Published var topArtists: [TopItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let userApiCaller = UserApiCaller.shared
    private let trackApiCaller = TrackApiCaller.shared
    
    init() {
        fetchHomeData()
    }

    func fetchHomeData() {
        isLoading = true
        errorMessage = nil

        // Dispatch group to handle multiple API calls
        let dispatchGroup = DispatchGroup()

        // Fetch User Profile
        dispatchGroup.enter()
        userApiCaller.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.userProfile = profile
                case .failure(let error):
                    self?.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                }
                dispatchGroup.leave()
            }
        }

        // Fetch User's Top Tracks
        dispatchGroup.enter()
        userApiCaller.getUserTopItems(type: "tracks") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.topTracks = tracks
                case .failure(let error):
                    self?.errorMessage = "Failed to load top tracks: \(error.localizedDescription)"
                }
                dispatchGroup.leave()
            }
        }

        // Fetch User's Top Artists
        dispatchGroup.enter()
        userApiCaller.getUserTopItems(type: "artists") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    self?.topArtists = artists
                case .failure(let error):
                    self?.errorMessage = "Failed to load top artists: \(error.localizedDescription)"
                }
                dispatchGroup.leave()
            }
        }


        // Completion handler for dispatch group
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
