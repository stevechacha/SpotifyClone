//
//  SpotifyHomeView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//

import SwiftUI

struct SpotifyHomeView: View {
    @StateObject private var viewModel = SpotifyHomeViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Filter Section
                    filterSection
                    
                    // Content
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        contentSection
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 40, height: 40)
            Spacer()
            HStack(spacing: 15) {
                Image(systemName: "bell")
                Image(systemName: "clock")
                Image(systemName: "gear")
            }
            .foregroundColor(.gray)
        }
        .padding()
    }

    private var filterSection: some View {
        HStack {
            ForEach([ContentType.all, .music, .podcasts], id: \.self) { type in
                Text(type == .all ? "All" : type == .music ? "Music" : "Podcasts")
                    .bold(type == viewModel.selectedFilter)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(type == viewModel.selectedFilter ? Color.green : Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(type == viewModel.selectedFilter ? .white : .primary)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedFilter = type
                        }
                    }
            }
        }
        .padding(.horizontal)
    }

    private var contentSection: some View {
        Group {
            if viewModel.selectedFilter == .all || viewModel.selectedFilter == .music {
                playlistGrid
            }
//            if viewModel.selectedFilter == .all || viewModel.selectedFilter == .podcasts {
//                podcastSection
//            }
            jumpBackInSection
        }
        .padding(.horizontal)
    }

    private var playlistGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(viewModel.playlists) { playlist in
                VStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 80)
                        .cornerRadius(10)
                    Text(playlist.name ?? "Unknown Playlist")
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
    }

    private var jumpBackInSection: some View {
        VStack(alignment: .leading) {
            Text("Jump back in")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.jumpBackIn) { item in
                        VStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            Text(item.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
    }

//    private var podcastSection: some View {
//        VStack(alignment: .leading) {
//            Text("Your Podcasts")
//                .font(.headline)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(viewModel.podcasts) { podcast in
//                        VStack {
//                            Rectangle()
//                                .fill(Color.blue.opacity(0.4))
//                                .frame(width: 100, height: 100)
//                                .cornerRadius(10)
//                            Text(podcast.show.name ?? "Unknown Podcast")
//                                .font(.caption)
//                                .lineLimit(1)
//                        }
//                    }
//                }
//            }
//        }
//    }
}

struct SpotifyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyHomeView()
    }
}
