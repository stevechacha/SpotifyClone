//
//  TrackDetailView.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit
import SwiftUICore
import SwiftUI

struct TrackDetailView: View {
    let track: Track

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Album Artwork
                AsyncImage(url: URL(string: track.album?.images?.first?.url ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(height: 300)
                .cornerRadius(12)
                .padding()

                // Track Name
                Text(track.name ?? "")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Artist Name
                Text(track.artists?.first?.name ?? "Unknown Artist")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Album Name
                Text("Album: \(track.album?.name ?? "Unknown Album")")
                    .font(.headline)
                    .padding(.top, 16)

                // Track Preview Link
                if let previewUrl = track.previewUrl {
                    Link("Listen to Preview", destination: URL(string: previewUrl)!)
                        .foregroundColor(.blue)
                        .font(.headline)
                        .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Track Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
