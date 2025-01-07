//
//  FollowedArtistAlbumCollectionViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/01/2025.
//


import UIKit
import SDWebImage

class FollowedArtistAlbumCollectionViewCell: UICollectionViewCell {
    static let identifier = "FollowedArtistAlbumCollectionViewCell"
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let tracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async { [weak self] in
            self?.setupViews()
        }
    }

    private func setupViews() {
        contentView.addSubview(albumImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(tracksLabel)
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        tracksLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Set albumImageView size to 100x60
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            albumImageView.widthAnchor.constraint(equalToConstant: 100),
            albumImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title label below the album image
            titleLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Artist label below the title
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Tracks label below the artist
            tracksLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 4),
            tracksLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tracksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            tracksLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with viewModel: FollowedArtistAlbumCellViewModel) {
        titleLabel.text = viewModel.name
        artistLabel.text = viewModel.artistName
        tracksLabel.text = viewModel.tracksText
        
        // Use SDWebImage to load the image with caching and a placeholder
        if let url = viewModel.artUrl {
            albumImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { [weak self] image, error, _, _ in
                if let error = error {
                    print("Failed to load image for \(self?.titleLabel.text ?? "unknown"): \(error.localizedDescription)")
                } else {
                    print("Image loaded successfully for: \(self?.titleLabel.text ?? "unknown")")
                }
            }
        } else {
            albumImageView.image = UIImage(named: "placeholder") // Replace with your placeholder image name
        }
    }
}

