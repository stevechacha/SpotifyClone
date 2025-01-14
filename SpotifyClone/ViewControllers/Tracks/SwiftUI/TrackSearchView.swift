//
//  TrackSearchView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import SwiftUI
import SwiftUI

struct TrackSearchView: View {
    @State private var searchText: String = ""
    @State private var tracks: [Track] = [] // Replace `Track` with your model
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    TextField("Search for tracks...", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button(action: searchTracks) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical)

                // Loading Indicator
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // Track List
                List(tracks, id: \.id) { track in
                    NavigationLink(destination: TrackDetailView(track: track)) {
                        HStack {
                            AsyncImage(url: URL(string: track.album?.images?.first?.url ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(track.name ?? "Unknown Track")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(track.artists?.first?.name ?? "Unknown Artist")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Tracks")
        }
    }

    private func searchTracks() {
        isLoading = true
        errorMessage = nil

        // Call the TrackApiCaller to search tracks
        TrackApiCaller.shared.searchTracks(query: searchText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let trackIDs):
                    // Fetch details of these tracks
                    TrackApiCaller.shared.getSeveralTracks(trackIDs: trackIDs) { tracksResult in
                        DispatchQueue.main.async {
                            switch tracksResult {
                            case .success(let response):
                                self.tracks = response.tracks
                            case .failure(let error):
                                self.errorMessage = "Failed to load tracks: \(error.localizedDescription)"
                            }
                        }
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to search tracks: \(error.localizedDescription)"
                }
            }
        }
    }
}

