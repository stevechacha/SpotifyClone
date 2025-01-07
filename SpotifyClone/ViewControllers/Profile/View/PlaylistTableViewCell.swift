//
//  PlaylistTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//


import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "PlaylistTableViewCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playlistOwnerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(playlistImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(playlistOwnerLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Playlist Image
            playlistImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            playlistImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playlistImageView.widthAnchor.constraint(equalToConstant: 50),
            playlistImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Playlist Name
            playlistNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            playlistNameLabel.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            playlistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Playlist Owner
            playlistOwnerLabel.topAnchor.constraint(equalTo: playlistNameLabel.bottomAnchor, constant: 4),
            playlistOwnerLabel.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 10),
            playlistOwnerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            playlistOwnerLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Cell
    
    func configure(with playlist: PlaylistItem) {
        playlistNameLabel.text = playlist.name
        playlistOwnerLabel.text = "By \(playlist.owner?.displayName ?? "Unknown")"
        
        if let imageUrl = playlist.images?.first?.url {
            playlistImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder")) { [weak self] image, error, _, _ in
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                } else {
                    print("Image loaded successfully for: \(self?.playlistNameLabel.text ?? "")")
                }
            }
        }
    }
}
