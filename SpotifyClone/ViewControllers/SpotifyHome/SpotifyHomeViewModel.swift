//
//  SpotifyHomeViewModel.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//


import SwiftUI
import Combine


// MARK: - Enum for Filter Types
enum ContentType {
    case all
    case music
    case podcasts
}

class SpotifyHomeViewModel: ObservableObject {
    @Published var playlists: [PlaylistItem] = []
    @Published var podcasts: [UsersSavedShowsItems] = []
    @Published var jumpBackIn: [TopItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedFilter: ContentType = .all

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchHomeData()
    }

    func fetchHomeData() {
        isLoading = true
        errorMessage = nil

        let dispatchGroup = DispatchGroup()
        var errors: [String] = []

        // Fetch playlists
        dispatchGroup.enter()
        PlaylistApiCaller.shared.getCurrentUsersPlaylist { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.playlists = response.items ?? []
                case .failure(let error):
                    errors.append("Playlists: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Fetch podcasts
        dispatchGroup.enter()
        ChapterApiCaller.shared.getUserSavedPodCasts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.podcasts = response.items ?? []
                case .failure(let error):
                    errors.append("Podcasts: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Fetch "Jump Back In"
        dispatchGroup.enter()
        UserApiCaller.shared.getUserTopItems(type: "artists") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.jumpBackIn = response
                case .failure(let error):
                    errors.append("Jump Back In: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Completion
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            if !errors.isEmpty {
                self.errorMessage = errors.joined(separator: "\n")
            }
        }
    }
}
