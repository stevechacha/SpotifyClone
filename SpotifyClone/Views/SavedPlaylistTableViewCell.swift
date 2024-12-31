//
//  SavedPlaylistTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit

class SavedPlaylistTableViewCell: UITableViewCell {
    static let identifier = "SavedPlaylistTableViewCell"
    
    private let playlistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let titleID: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    private func setupUI() {
        contentView.addSubview(playlistImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleID)
        
        playlistImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleID.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playlistImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            playlistImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playlistImageView.widthAnchor.constraint(equalToConstant: 60),
            playlistImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            titleID.leadingAnchor.constraint(equalTo: playlistImageView.trailingAnchor, constant: 15),
            titleID.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleID.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            titleID.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with playlist: PlaylistItem) {
        titleLabel.text = playlist.name
        titleID.text = playlist.id
        if let imageUrlString = playlist.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.playlistImageView.image = image
                }
            }
        }
    }
}
