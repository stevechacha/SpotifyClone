//
//  TracksViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit

//class TracksViewController: UIViewController {
//
//    private var track: Track?
//
//    private let trackID: String
//
//    private let albumImageView = UIImageView()
//    private let trackNameLabel = UILabel()
//    private let artistLabel = UILabel()
//    private let albumLabel = UILabel()
//    private let durationLabel = UILabel()
//    private let popularityLabel = UILabel()
//    private let previewButton = UIButton(type: .system)
//
//    // Custom initializer accepting a track ID
//    init(trackID: String) {
//        self.trackID = trackID
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Track Details"
//        view.backgroundColor = .systemBackground
//
//        setupUI()
//        fetchTrackDetails()
//    }
//
//    private func setupUI() {
//        // Configure albumImageView
//        albumImageView.contentMode = .scaleAspectFill
//        albumImageView.clipsToBounds = true
//        albumImageView.layer.cornerRadius = 10
//        albumImageView.translatesAutoresizingMaskIntoConstraints = false
//
//        // Configure labels
//        trackNameLabel.textAlignment = .center
//        trackNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
//        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        artistLabel.textAlignment = .center
//        artistLabel.font = .systemFont(ofSize: 16)
//        artistLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        albumLabel.textAlignment = .center
//        albumLabel.font = .systemFont(ofSize: 14)
//        albumLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        durationLabel.textAlignment = .center
//        durationLabel.font = .systemFont(ofSize: 14)
//        durationLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        popularityLabel.textAlignment = .center
//        popularityLabel.font = .systemFont(ofSize: 14)
//        popularityLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        previewButton.setTitle("Play Preview", for: .normal)
//        previewButton.addTarget(self, action: #selector(playPreview), for: .touchUpInside)
//        previewButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Add subviews
//        view.addSubview(albumImageView)
//        view.addSubview(trackNameLabel)
//        view.addSubview(artistLabel)
//        view.addSubview(albumLabel)
//        view.addSubview(durationLabel)
//        view.addSubview(popularityLabel)
//        view.addSubview(previewButton)
//
//        // Layout constraints
//        NSLayoutConstraint.activate([
//            albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            albumImageView.widthAnchor.constraint(equalToConstant: 200),
//            albumImageView.heightAnchor.constraint(equalToConstant: 200),
//
//            trackNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            trackNameLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 20),
//
//            artistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            artistLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 10),
//
//            albumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            albumLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 10),
//
//            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            durationLabel.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 10),
//
//            popularityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            popularityLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
//
//            previewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            previewButton.topAnchor.constraint(equalTo: popularityLabel.bottomAnchor, constant: 20),
//        ])
//    }
//
//    private func fetchTrackDetails() {
//        TrackApiCaller.shared.getTrack(trackID: trackID) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let track):
//                    self?.track = track
//                    self?.updateUI(with: track)
//                case .failure(let error):
//                    self?.showErrorAlert(message: error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    private func updateUI(with track: Track) {
//        trackNameLabel.text = "Track: \(track.name ?? "Unknown Track")"
//        artistLabel.text = "Artist: \(track.artists?.first?.name ?? "Unknown Artist")"
//        albumLabel.text = "Album: \(track.album?.name ?? "Unknown Album")"
//        
//        // Convert duration to minutes:seconds
//        if let durationMs = track.durationMs {
//            durationLabel.text = "Duration: \(formatDuration(durationMs))"
//        } else {
//            durationLabel.text = "Duration: N/A"
//        }
//        
//        popularityLabel.text = "Popularity: \(track.popularity ?? 0)"
//        previewButton.isHidden = track.previewUrl == nil
//
//        // Load album image
//        if let imageUrlString = track.album?.images?.first?.url,
//           let imageUrl = URL(string: imageUrlString) {
//            loadImage(from: imageUrl) { [weak self] image in
//                DispatchQueue.main.async {
//                    self?.albumImageView.image = image
//                }
//            }
//        }
//    }
//
//
//    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(nil)
//                return
//            }
//            completion(UIImage(data: data))
//        }.resume()
//    }
//
//    private func showErrorAlert(message: String) {
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    @objc private func playPreview() {
//        guard let previewUrl = track?.previewUrl, let url = URL(string: previewUrl) else {
//            let alert = UIAlertController(title: "Error", message: "No preview available for this track.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//            return
//        }
//
//        // Open the preview URL in Safari
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//    }
//    
//    private func formatDuration(_ milliseconds: Int) -> String {
//        let seconds = milliseconds / 1000
//        let minutes = seconds / 60
//        let remainingSeconds = seconds % 60
//        return String(format: "%d:%02d", minutes, remainingSeconds)
//    }
//
//}



class TrackTableViewCell: UITableViewCell {
    let trackNameLabel = UILabel()
    let artistNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            trackNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with track: Track) {
        trackNameLabel.text = track.name
        artistNameLabel.text = track.artists?.description
    }
}
