//
//  PlaylistView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//

import SwiftUI

struct PlaylistView: View {
    @StateObject private var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let playlists = viewModel.userPlaylists {
                        Text("Your Playlists")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(playlists.items ?? [], id: \.id) { playlist in
                            HStack {
                                if let imageUrl = playlist.images?.first?.url,
                                   let url = URL(string: imageUrl) {
                                    AsyncImage(url: url)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                }
                                Text(playlist.name)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Playlists")
            .onAppear {
                viewModel.fetchUserPlaylists()
            }
        }
    }
}


#Preview {
    PlaylistView()
}
