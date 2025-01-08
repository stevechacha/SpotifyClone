//
//  PlaylistDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit

class PlaylistDetailViewController: UIViewController {
    private let playlistID: String

        
    private let playlistImageView = UIImageView()
    private let playlistDescriptionLabel = UILabel()

    init(playlistID: String) {
        self.playlistID = playlistID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Playlist Detail"
        setupUI()
    }

    private func setupUI() {
        playlistImageView.translatesAutoresizingMaskIntoConstraints = false
        playlistImageView.contentMode = .scaleAspectFit
        view.addSubview(playlistImageView)

        playlistDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistDescriptionLabel.numberOfLines = 0
        view.addSubview(playlistDescriptionLabel)

        NSLayoutConstraint.activate([
            playlistImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playlistImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playlistImageView.widthAnchor.constraint(equalToConstant: 200),
            playlistImageView.heightAnchor.constraint(equalToConstant: 200),

            playlistDescriptionLabel.topAnchor.constraint(equalTo: playlistImageView.bottomAnchor, constant: 20),
            playlistDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playlistDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

//        // Set playlist details
//        playlistImageView.image = UIImage(named: playlist.imageName ?? "placeholder")
//        playlistDescriptionLabel.text = playlist.description
    }
}

