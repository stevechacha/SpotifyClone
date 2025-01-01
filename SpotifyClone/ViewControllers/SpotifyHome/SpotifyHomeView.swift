//
//  SpotifyHomeView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 01/01/2025.
//

import SwiftUI


struct SpotifyHomeView: View {
    let playlists = [
        "Daily Mix 2", "First Of All", "Nandy Radio",
        "Notos", "Alusa Why Are You Topless?",
        "Maisha Ya Stunna", "Albu", "Afro Station"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
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
                    
                    // Filter Section
                    HStack {
                        Text("All")
                            .bold()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                        Text("Music")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                        Text("Podcasts")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Playlist Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(playlists, id: \.self) { playlist in
                            VStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(height: 80)
                                    .cornerRadius(10)
                                Text(playlist)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Picked for You Section
                    VStack(alignment: .leading) {
                        Text("Picked for you")
                            .font(.headline)
                            .padding(.horizontal)
                        HStack {
                            Rectangle()
                                .fill(Color.pink)
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                            VStack(alignment: .leading) {
                                Text("Viral Hits Africa")
                                    .font(.title3)
                                    .bold()
                                Text("All the vibes, enjoyment, and future hits right here")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                    
                    // Jump Back In Section
                    VStack(alignment: .leading) {
                        Text("Jump back in")
                            .font(.headline)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5) { _ in
                                    VStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.4))
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                        Text("Artist Name")
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SpotifyHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyHomeView()
    }
}

