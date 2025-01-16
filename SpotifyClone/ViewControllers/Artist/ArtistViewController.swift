//
//  ArtistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 28/12/2024.
//

import UIKit


class ArtistViewController: UIViewController {

    // MARK: - Properties

    private let topArtistID: String
    private var topTracks: [Track] = []
    private var albums: [Album] = []
    private var relatedArtists: [RelatedArtist] = []
    private var artistName: String = "Artist" {
        didSet { self.title = artistName }
    }

    // MARK: - UI Components
    private var headerView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Initializer

    init(artistID: String) {
        self.topArtistID = artistID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchInitialData()
    }

    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupHeaderView()
        setupSegmentedControl()
        setupTableView()
        setupLoadingIndicator()
    }

    private func setupHeaderView() {
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let artistImageView = createArtistImageView()
        let nameLabel = createNameLabel()
        let detailsLabel = createDetailsLabel()
        let aboutLabel = createAboutLabel()

        headerView.addSubview(artistImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(detailsLabel)
        headerView.addSubview(aboutLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),

            artistImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            artistImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            artistImageView.widthAnchor.constraint(equalToConstant: 100),
            artistImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),

            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            detailsLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
            detailsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),

            aboutLabel.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 10),
            aboutLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            aboutLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            aboutLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])

        fetchArtistDetails(
            imageView: artistImageView,
            nameLabel: nameLabel,
            detailsLabel: detailsLabel,
            aboutLabel: aboutLabel
        )
    }
    
    

    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Top Tracks", "Albums", "Related Artists"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupLoadingIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }

    // MARK: - Helper Methods
    private func fetchInitialData() {
        fetchTopTracks()
        fetchAlbums()
        fetchRelatedArtists()
    }

    private func fetchArtistDetails(imageView: UIImageView, nameLabel: UILabel, detailsLabel: UILabel, aboutLabel: UILabel) {
        ArtistApiCaller.shared.getArtistDetails(artistID: topArtistID) { [weak self] result in
            DispatchQueue.main.async { self?.stopLoadingIndicator() }

            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    self?.artistName = details.name ?? ""
                    nameLabel.text = details.name
                    detailsLabel.text = self?.formatArtistDetails(details: details)
                    aboutLabel.text = details.bio ?? "No description available."
                    self?.loadImage(from: details.images?.first?.url, into: imageView)
                }
            case .failure(let error):
                print("Error fetching artist details: \(error)")
            }
        }
    }


    private func formatArtistDetails(details: SpotifyArtistsDetailResponse) -> String {
        let genres = details.genres?.joined(separator: ", ").capitalized ?? "Unknown Genres"
        let followers = details.followers?.total ?? 0
        return "Genres: \(genres)\nFollowers: \(followers)"
    }
    
   

    private func loadImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person"))
    }

    @objc private func segmentChanged() {
        tableView.reloadData()
    }

    private func startLoadingIndicator() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }

    private func stopLoadingIndicator() {
        DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
    }

    // MARK: - Fetch Methods

    private func fetchTopTracks() {
        ArtistApiCaller.shared.getArtistsTopTracks(for: topArtistID) { [weak self] result in
            switch result {
            case .success(let tracksResponse):
                self?.topTracks = tracksResponse.tracks
                DispatchQueue.main.async { self?.tableView.reloadData() }
            case .failure(let error):
                print("Error fetching top tracks: \(error)")
            }
        }
    }
    private func fetchArtistDetails() {
        ArtistApiCaller.shared.getArtistDetails(artistID: topArtistID) { [weak self] result in
            switch result {
            case .success(let details):
                DispatchQueue.main.async {
                    self?.artistName = details.name ?? ""
                    let genres = details.genres?.joined(separator: ", ").capitalized ?? "Unknown Genres"
                    let followers = details.followers?.total ?? 0
                    let headerDetails = "Genres: \(genres)\nFollowers: \(followers)"
                    // Update UI with artist name, genres, and followers
                }
            case .failure(let error):
                print("Error fetching artist details: \(error)")
            }
        }
    }


    private func fetchAlbums() {
        ArtistApiCaller.shared.getArtistAlbums(artistID: topArtistID) { [weak self] result in
            switch result {
            case .success(let albumsResponse):
                self?.albums = albumsResponse.items
                DispatchQueue.main.async { self?.tableView.reloadData() }
            case .failure(let error):
                print("Error fetching albums: \(error)")
            }
        }
    }

    private func fetchRelatedArtists() {
        ArtistApiCaller.shared.getRelatedArtists(artistID: topArtistID) { [weak self] result in
            switch result {
            case .success(let relatedArtistsResponse):
                self?.relatedArtists = relatedArtistsResponse.artists ?? []
                DispatchQueue.main.async { self?.tableView.reloadData() }
            case .failure(let error):
                print("Error fetching related artists: \(error)")
            }
        }
    }

    private func createArtistImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private func createNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.text = "Loading..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func createDetailsLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createAboutLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textColor = .secondaryLabel
        label.text = "About the Artist"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }


}

// MARK: - TableView Data Source & Delegate

extension ArtistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return topTracks.count
        case 1: return albums.count
        case 2: return relatedArtists.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        configure(cell, for: indexPath)
        return cell
    }

    private func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        // Clear existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView()
        let label = UILabel()

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false

        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),

            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            label.text = topTracks[indexPath.row].name
            loadImage(from: topTracks[indexPath.row].album?.images?.first?.url, into: imageView)
        case 1:
            label.text = albums[indexPath.row].name
            loadImage(from: albums[indexPath.row].images?.first?.url, into: imageView)
        case 2:
            label.text = relatedArtists[indexPath.row].name
            loadImage(from: relatedArtists[indexPath.row].images?.first?.url, into: imageView)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}
