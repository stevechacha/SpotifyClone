//
//  TrackDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit

class TrackDetailViewController: UIViewController {
    private let track: Track

    // UI Elements
    private let albumImageView = UIImageView()
    private let trackNameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let albumNameLabel = UILabel()
    private let previewButton = UIButton(type: .system)

    init(track: Track) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureUI()
    }

    private func setupUI() {
        // Album Artwork
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.contentMode = .scaleAspectFit
        albumImageView.layer.cornerRadius = 12
        albumImageView.clipsToBounds = true
        view.addSubview(albumImageView)

        // Track Name Label
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        trackNameLabel.textAlignment = .center
        trackNameLabel.numberOfLines = 0
        view.addSubview(trackNameLabel)

        // Artist Name Label
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.font = .systemFont(ofSize: 18, weight: .regular)
        artistNameLabel.textColor = .secondaryLabel
        artistNameLabel.textAlignment = .center
        artistNameLabel.numberOfLines = 0
        view.addSubview(artistNameLabel)

        // Album Name Label
        albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        albumNameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        albumNameLabel.textColor = .secondaryLabel
        albumNameLabel.textAlignment = .center
        albumNameLabel.numberOfLines = 0
        view.addSubview(albumNameLabel)

        // Preview Button
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.setTitle("Listen to Preview", for: .normal)
        previewButton.setTitleColor(.systemBlue, for: .normal)
        previewButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        previewButton.layer.cornerRadius = 8
        previewButton.backgroundColor = .systemGray6
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)
        view.addSubview(previewButton)

        // Layout Constraints
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumImageView.widthAnchor.constraint(equalToConstant: 200),
            albumImageView.heightAnchor.constraint(equalToConstant: 200),

            trackNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 20),
            trackNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 10),
            artistNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            artistNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            albumNameLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 10),
            albumNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            albumNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            previewButton.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 30),
            previewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewButton.widthAnchor.constraint(equalToConstant: 200),
            previewButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureUI() {
        // Configure UI with track details
        if let albumImageUrl = URL(string: track.album?.images?.first?.url ?? "") {
            // Load the album image (you could use a library like SDWebImage or URLSession for async loading)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: albumImageUrl) {
                    DispatchQueue.main.async {
                        self.albumImageView.image = UIImage(data: data)
                    }
                }
            }
        }

        trackNameLabel.text = track.name
        artistNameLabel.text = track.artists?.first?.name ?? "Unknown Artist"
        albumNameLabel.text = "Album: \(track.album?.name ?? "Unknown Album")"

        // Hide preview button if preview URL is missing
        if track.previewUrl == nil {
            previewButton.isHidden = true
        }
    }

    @objc private func previewButtonTapped() {
        guard let previewUrlString = track.previewUrl,
              let previewUrl = URL(string: previewUrlString) else { return }

        // Open the preview URL in the default browser
        UIApplication.shared.open(previewUrl, options: [:], completionHandler: nil)
    }
}
