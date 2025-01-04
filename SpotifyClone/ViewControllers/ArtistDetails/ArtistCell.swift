//
//  ArtistCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/01/2025.
//

import UIKit


class ArtistCell: UICollectionViewCell {
    static let identifier = "ArtistCell"

    
    // MARK: - UI Elements
    
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6 // Placeholder background
        return imageView
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(artistImageView)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(infoLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Method
    
    func configure(with artist: TopItem) {
        artistNameLabel.text = artist.name
        
        // Example for infoLabel: Popularity or albums count
        infoLabel.text = "\(artist.popularity ?? 0)% Popularity"
        
        // Load the artist image
        if let imageUrl = artist.images?.first?.url, let url = URL(string: imageUrl) {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.artistImageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Layout
    
    private func setupConstraints() {
        artistImageView.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Artist Image
            artistImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            artistImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            artistImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            artistImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor), // Square image
            
            // Artist Name
            artistNameLabel.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 8),
            artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            // Info Label
            infoLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}
