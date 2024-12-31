//
//  SavedEpisodeTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit

class SavedEpisodeTableViewCell: UITableViewCell {
    
    static let identifier = "SavedEpisodeTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let episodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    // This is where you set up the UI elements and layout
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(episodeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        episodeImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            episodeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            episodeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            episodeImageView.widthAnchor.constraint(equalToConstant: 60),
            episodeImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: episodeImageView.trailingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // Method to configure the cell with a `UserSavedEpisode` object
    func configure(with episode: UserSavedEpisode) {
        titleLabel.text = episode.episode?.name
        descriptionLabel.text = episode.episode?.description ?? "No description available."
        
        // Assuming episode has an image URL, load the image
        if let imageUrl = episode.episode?.images?.first?.url, let url = URL(string: imageUrl) {
            // Load image asynchronously
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        // Use a simple image loading method (considering caching with a library like SDWebImage or similar)
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.episodeImageView.image = image
            }
        }.resume()
    }
}
