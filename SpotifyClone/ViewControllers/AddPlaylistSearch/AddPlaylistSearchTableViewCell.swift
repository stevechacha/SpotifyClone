//
//  AddPlaylistSearchTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 15/01/2025.
//

import UIKit

protocol AddPlaylistSearchTableViewCellDelegate: AnyObject {
    func didTapAddButton(on cell: AddPlaylistSearchTableViewCell)
}


class AddPlaylistSearchTableViewCell: UITableViewCell {
    static let identifier = "AddPlaylistTableViewCell"
    
    weak var delegate: AddPlaylistSearchTableViewCellDelegate?
    
    // Image view for album art
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8 // Rounded corners
        return imageView
    }()
    
    // Label for song title
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label // Adapts to light/dark mode
        label.numberOfLines = 1
        return label
    }()
    
    // Label for artist names
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel // Adapts to light/dark mode
        label.numberOfLines = 1
        return label
    }()
    
    // Add button (e.g., for adding to a playlist)
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside) // Set target here
        button.tintColor = .label // Matches text color
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground // Dynamically adapts to light/dark mode
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(albumImageView)
        contentView.addSubview(songTitleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(addButton)
        
        // Constraints for albumImageView
        NSLayoutConstraint.activate([
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            albumImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 56), // Slightly larger size
            albumImageView.heightAnchor.constraint(equalToConstant: 56),
        ])
        
        // Constraints for songTitleLabel
        NSLayoutConstraint.activate([
            songTitleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 16),
            songTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            songTitleLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
        ])
        
        // Constraints for artistLabel
        NSLayoutConstraint.activate([
            artistLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 16),
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 4),
            artistLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -12),
        ])
        
        // Constraints for addButton
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24),
        ])
        
        // Action for Add Button
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        delegate?.didTapAddButton(on: self)
    }
    
    // MARK: - Configuration
    func configure(with result: SearchResult) {
        switch result {
        case .track(let track):
            songTitleLabel.text = track.name
            artistLabel.text = "Track"
            if let imageUrl = track.album?.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                albumImageView.image = UIImage(systemName: "music.note") // Placeholder
            }
            
        case .artist(let artist):
            songTitleLabel.text = artist.name
            artistLabel.text = "Artist"
            if let imageUrl = artist.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .album(let album):
            songTitleLabel.text = album.name
            artistLabel.text = "Album"
            if let imageUrl = album.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .playlist(let playlist):
            songTitleLabel.text = playlist.name
            artistLabel.text = "Playlist"
            if let imageUrl = playlist.images?.first?.url {
                loadImage(from: imageUrl)
            }
        case .audiobook(let audiobook):
            songTitleLabel.text = audiobook.name
            artistLabel.text = "Audiobook"
            if let imageUrl = audiobook.images?.first?.url {
                loadImage(from: imageUrl)
            }
        case .show(let show):
            songTitleLabel.text = show.name
            artistLabel.text = "Show"
            if let imageUrl = show.images?.first?.url {
                loadImage(from: imageUrl)
            }
            
        case .episode(let episode):
            songTitleLabel.text = episode.name
            artistLabel.text = "Episode"
            if let imageUrl = episode.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                albumImageView.image = UIImage(systemName: "mic") // Placeholder
            }
            
        case .chapter(let chapter):
            songTitleLabel.text = chapter.name
            artistLabel.text = "Chapter"
            if let imageUrl = chapter.images?.first?.url {
                loadImage(from: imageUrl)
            } else {
                albumImageView.image = UIImage(systemName: "book") // Placeholder
            }
        }
    }
    
    // MARK: - Load Image
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.albumImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    
//    // Function to configure cell
//    func configureCell(with viewModel: AddPlaylistCellViewModel) {
//        songTitleLabel.text = viewModel.trackName
//        artistLabel.text = viewModel.trackArtist
//        
//        if let url = viewModel.trackArtUrl {
//            albumImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
//        } else {
//            albumImageView.image = UIImage(named: "placeholder") // Replace with your placeholder image name
//        }
//    }
}

