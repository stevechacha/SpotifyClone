//
//  PlayListTrackCollectionViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import UIKit

class PlayListTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "PlayListTrackCollectionViewCell"
    
    // Track Image
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Track Name Label
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Artist Name Label
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Menu Button
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        // Add subviews
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(menuButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Track image
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Track name label
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            trackNameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -10),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            // Artist name label
            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            artistNameLabel.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -10),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            
            // Menu button
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 30),
            menuButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with trackItem: PlaylistItemsResponse) {
        trackNameLabel.text = trackItem.track?.name
        artistNameLabel.text = trackItem.track?.artists?.compactMap { $0.name }.joined(separator: ", ")
        
        if let imageUrl = trackItem.track?.album?.images?.first?.url, let url = URL(string: imageUrl) {
            fetchImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.trackImageView.image = image
                }
            }
        } else {
            trackImageView.image = UIImage(systemName: "music.note")
        }
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
        task.resume()
    }
}
