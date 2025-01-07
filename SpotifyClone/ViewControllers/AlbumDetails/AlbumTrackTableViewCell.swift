//
//  AlbumTrackTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//


import UIKit
import SDWebImage

class AlbumTrackTableViewCell: UITableViewCell {
    static let identifier = "TrackTableViewCell"
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(durationLabel)
        
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Track Image View
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 60),
            trackImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Track Name Label
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 8),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Artist Name Label
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 8),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Duration Label
            durationLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.name
        artistNameLabel.text = track.artists?.map { $0.name ?? "" }.joined(separator: ", ") ?? "Unknown Artist"
        
        let durationMinutes = track.durationMs! / 1000 / 60
        let durationSeconds = (track.durationMs! / 1000) % 60
        durationLabel.text = "Duration: \(durationMinutes):\(String(format: "%02d", durationSeconds))"
        
        // Use SDWebImage to load track image
        if let imageUrlString = track.album?.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
            trackImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "music.note"), options: .highPriority, completed: nil)
        } else {
            trackImageView.image = UIImage(systemName: "music.note") // Placeholder image
        }
    }
}