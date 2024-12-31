//
//  SavedPodcastTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit

class SavedPodcastTableViewCell: UITableViewCell {
    static let identifier = "SavedPodcastTableViewCell"
    
    private let podcastImageView: UIImageView = {
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
    
    private let titleId: UILabel = {
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
        contentView.addSubview(podcastImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleId)
        
        podcastImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleId.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            podcastImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            podcastImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            podcastImageView.widthAnchor.constraint(equalToConstant: 60),
            podcastImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: podcastImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            titleId.leadingAnchor.constraint(equalTo: podcastImageView.trailingAnchor, constant: 15),
            titleId.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleId.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            titleId.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with podcast: UsersSavedShowsItems) {
        titleLabel.text = podcast.show.name
        titleId.text = podcast.show.id
        if let imageUrlString = podcast.show.images?.first?.url, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.podcastImageView.image = image
                }
            }
        }
    }
}
