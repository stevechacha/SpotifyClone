//
//  SavedAlbumTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit

class SavedAlbumTableViewCell: UITableViewCell {
    static let identifier = "SavedAlbumTableViewCell"
    
    private let albumImageView: UIImageView = {
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
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
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
        contentView.addSubview(albumImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            albumImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 60),
            albumImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            artistLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 15),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
   
    
    func configure(with album: Album) {
        titleLabel.text = album.name ?? "Unknown Album"
        artistLabel.text = album.artists?.map { $0.name ?? "default value" }.joined(separator: ", ") ?? "Unknown Artist"
        
        if let imageUrl = album.images?.first?.url {
            albumImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder")) { [weak self] image, error, _, _ in
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                } else {
                    print("Image loaded successfully for: \(self?.titleLabel.text ?? "")")
                }
            }
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.albumImageView.image = image
                }
            }
        }
    }
}
