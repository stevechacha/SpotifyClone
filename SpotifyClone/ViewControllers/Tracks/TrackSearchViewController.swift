//
//  TrackSearchViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit


class TrackSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var tracks: [Track] = [] // Replace `Track` with your model
    private var isLoading: Bool = false
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Configure Search Bar
        searchBar.delegate = self
        searchBar.placeholder = "Search for tracks..."
        navigationItem.titleView = searchBar

        // Configure Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: "TrackCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Configure Loading Indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        // Layout Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchTracks(query: query)
    }

    private func searchTracks(query: String) {
        isLoading = true
        loadingIndicator.startAnimating()

        TrackApiCaller.shared.searchTracks(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let trackIDs):
                    // Fetch details of these tracks
                    TrackApiCaller.shared.getSeveralTracks(trackIDs: trackIDs) { tracksResult in
                        DispatchQueue.main.async {
                            switch tracksResult {
                            case .success(let response):
                                self?.tracks = response.tracks
                                self?.tableView.reloadData()
                            case .failure(let error):
                                self?.showError(message: "Failed to load tracks: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    self?.showError(message: "Failed to search tracks: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - Table View DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TracksTableViewCell
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        let detailVC = TrackDetailViewController(track: track)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


class TracksTableViewCell: UITableViewCell {
    private let trackImageView = UIImageView()
    private let trackNameLabel = UILabel()
    private let artistNameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        trackImageView.translatesAutoresizingMaskIntoConstraints = false
        trackImageView.contentMode = .scaleAspectFill
        trackImageView.clipsToBounds = true
        trackImageView.layer.cornerRadius = 8
        contentView.addSubview(trackImageView)

        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        trackNameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(trackNameLabel)

        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.font = .systemFont(ofSize: 14, weight: .regular)
        artistNameLabel.textColor = .gray
        contentView.addSubview(artistNameLabel)

        // Layout Constraints
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),

            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 12),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 12),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with track: Track) {
        trackNameLabel.text = track.name
        artistNameLabel.text = track.artists?.first?.name
        if URL(string: track.album?.images?.first?.url ?? "") != nil {
            // Load the image asynchronously
        }
    }
}

