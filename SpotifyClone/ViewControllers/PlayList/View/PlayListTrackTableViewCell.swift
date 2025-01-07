//
//  PlayListTrackTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//


import UIKit

class PlayListTrackTableViewCell: UITableViewCell {
    
    static let identifier = "PlayListTrackTableViewCell"
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 12),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 12),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Cell
    
    func configure(with trackItem: PlaylistItemsResponse) {
        trackNameLabel.text = trackItem.track?.name
        artistNameLabel.text = trackItem.track?.artists?.map { $0.name ?? "" }.joined(separator: ", ")
        
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
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}




