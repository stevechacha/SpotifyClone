//
//  PlaylistHeaderCollectionReusableViewDelegate.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func didTapDownloadButton(_ header: PlaylistHeaderCollectionReusableView)
    func didTapAddButton(_ header: PlaylistHeaderCollectionReusableView)
    func didTapOptionsButton(_ header: PlaylistHeaderCollectionReusableView)
    func didTapPlayButton(_ header: PlaylistHeaderCollectionReusableView)
    func didTapAddToPlaylistButton(_ header: PlaylistHeaderCollectionReusableView)
}






class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderReusableView"

    weak var delegate: PlaylistHeaderCollectionReusableViewDelegate?

    // MARK: - UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let ownerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15 // Circular shape
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idAndDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tintColor = .systemGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addToPlaylistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to this playlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActions() {
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        addToPlaylistButton.addTarget(self, action: #selector(addToPlaylistButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func downloadButtonTapped() {
        delegate?.didTapDownloadButton(self)
    }
    
    @objc private func addButtonTapped() {
        delegate?.didTapAddButton(self)
    }
    
    @objc private func optionsButtonTapped() {
        delegate?.didTapOptionsButton(self)
    }
    
    @objc private func playButtonTapped() {
        delegate?.didTapPlayButton(self)
    }
    
    @objc private func addToPlaylistButtonTapped() {
        delegate?.didTapAddToPlaylistButton(self)
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        // Add subviews
        addSubview(imageView)
        addSubview(ownerImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(detailLabel)
        addSubview(idAndDurationLabel)
        addSubview(downloadButton)
        addSubview(addButton)
        addSubview(optionsButton)
        addSubview(playButton)
        addSubview(addToPlaylistButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // ImageView
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Owner Image View
            ownerImageView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            ownerImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            ownerImageView.widthAnchor.constraint(equalToConstant: 30),
            ownerImageView.heightAnchor.constraint(equalToConstant: 30),
            
            // Title Label
            titleLabel.centerYAnchor.constraint(equalTo: ownerImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: ownerImageView.trailingAnchor, constant: 10),
            
            // ID and Duration Label
            idAndDurationLabel.centerYAnchor.constraint(equalTo: ownerImageView.centerYAnchor),
            idAndDurationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: ownerImageView.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            // Detail Label
            detailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            // Buttons
            downloadButton.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 15),
            downloadButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            downloadButton.widthAnchor.constraint(equalToConstant: 30),
            downloadButton.heightAnchor.constraint(equalToConstant: 30),
            
            addButton.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: downloadButton.trailingAnchor, constant: 20),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            
            optionsButton.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            optionsButton.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 20),
            optionsButton.widthAnchor.constraint(equalToConstant: 30),
            optionsButton.heightAnchor.constraint(equalToConstant: 30),
            
            playButton.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Add to Playlist Button
            addToPlaylistButton.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 20),
            addToPlaylistButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            addToPlaylistButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            addToPlaylistButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    // MARK: - Configure
    
    func configure(with viewModel: PlaylistHeaderViewModel) {
        titleLabel.text = viewModel.playlistName
        subtitleLabel.text = viewModel.ownerName
        detailLabel.text = viewModel.description
        idAndDurationLabel.text = "\(viewModel.userId ?? "") • \(viewModel.playlistDuration ?? "")"
        imageView.sd_setImage(with: viewModel.artUrl, completed: nil)
        ownerImageView.sd_setImage(with: viewModel.ownerArtUrl, completed: nil)
    }
}

