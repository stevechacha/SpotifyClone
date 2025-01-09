//
//  HomeView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        // User Profile Section
                        if let user = viewModel.userProfile {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome, \(user.display_name ?? "")!")
                                    .font(.title)
                                    .bold()
                                if let imageUrl = user.images?.first?.url {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Top Tracks Section
                        if !viewModel.topTracks.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Top Tracks")
                                    .font(.headline)
                                    .bold()
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.topTracks, id: \.id) { track in
                                            VStack {
                                                if let imageUrl = track.images?.first?.url {
                                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .frame(width: 100, height: 100)
                                                            .cornerRadius(8)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                                Text(track.name)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }

                        // Top Artists Section
                        if !viewModel.topArtists.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Top Artists")
                                    .font(.headline)
                                    .bold()
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.topArtists, id: \.id) { artist in
                                            VStack {
                                                if let imageUrl = artist.images?.first?.url {
                                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .frame(width: 100, height: 100)
                                                            .cornerRadius(8)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                }
                                                Text(artist.name)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .onAppear {
                viewModel.fetchHomeData()
            }
        }
    }
}



struct UIKitWrapperView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return HomeViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}




#Preview {
    HomeView()
}
