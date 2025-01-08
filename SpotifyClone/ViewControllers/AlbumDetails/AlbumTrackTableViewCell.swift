//
//  AlbumTrackTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 07/01/2025.
//


import UIKit
import SDWebImage

class AlbumTrackTableViewCell: UITableViewCell {
    
    static let identifier = "AlbumTrackTableViewCell"
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(durationLabel)
        
        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 40),
            trackImageView.heightAnchor.constraint(equalToConstant: 40),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 8),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            durationLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            durationLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackImageView.image = nil
        trackNameLabel.text = nil
        durationLabel.text = nil
    }
    
    func configure(with track: Track) {
        trackNameLabel.text = track.name
        let minutes = track.durationMs! / 1000 / 60
        let seconds = (track.durationMs! / 1000) % 60
        durationLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        // Optional track image
        if let imageUrlString = track.album?.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
            trackImageView.sd_setImage(with: imageUrl, completed: nil)
        }
    }
}
