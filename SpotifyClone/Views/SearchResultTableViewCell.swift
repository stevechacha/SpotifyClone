//
//  SearchResultTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//


import UIKit

class SearchResultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultTableViewCell"
    
    // UI Elements
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(genresLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Image View
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Type Label
            typeLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Genres Label
            genresLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            genresLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            genresLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configuration
    func configure(with result: SearchResult) {
        switch result {
        case .track(let track):
            nameLabel.text = track.name
            typeLabel.text = "Track"
            genresLabel.text = nil
            if let imageUrl = track.album?.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                itemImageView.image = UIImage(systemName: "music.note") // Placeholder
            }
            
        case .artist(let artist):
            nameLabel.text = artist.name
            typeLabel.text = "Artist"
            genresLabel.text = artist.genres?.joined(separator: ", ")
            if let imageUrl = artist.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .album(let album):
            nameLabel.text = album.name
            typeLabel.text = "Album"
            genresLabel.text = nil
            if let imageUrl = album.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .playlist(let playlist):
            nameLabel.text = playlist.name
            typeLabel.text = "Playlist"
            genresLabel.text = nil
            if let imageUrl = playlist.images?.first?.url {
                loadImage(from: imageUrl)
            }
        case .audiobook(let audiobook):
            nameLabel.text = audiobook.name
            typeLabel.text = "Audiobook"
            genresLabel.text = nil
            if let imageUrl = audiobook.images?.first?.url {
                loadImage(from: imageUrl)
            }
        case .show(let show):
            nameLabel.text = show.name
            typeLabel.text = "Show"
            genresLabel.text = nil
            if let imageUrl = show.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .episode(let episode):
            nameLabel.text = episode.name
            typeLabel.text = "Episode"
            genresLabel.text = nil
            if let imageUrl = episode.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                itemImageView.image = UIImage(systemName: "mic") // Placeholder
            }
            
        case .chapter(let chapter):
            nameLabel.text = chapter.name
            typeLabel.text = "Chapter"
            genresLabel.text = nil
            if let imageUrl = chapter.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                itemImageView.image = UIImage(systemName: "book") // Placeholder
            }
        }
    }
    
    // MARK: - Load Image
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.itemImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

