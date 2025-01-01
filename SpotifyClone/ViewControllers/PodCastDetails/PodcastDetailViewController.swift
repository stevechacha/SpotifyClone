//
//  PodcastDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit

import UIKit

class PodcastDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let podcast: UsersSavedShowsItems // Podcast (show) data
    private var episodes: [Episode] = [] // Episodes for the podcast
    private var isLoading: Bool = true // Track loading state

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PodcastEpisodeTableViewCell.self, forCellReuseIdentifier: PodcastEpisodeTableViewCell.identifier)
        return tableView
    }()

    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .gray
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Failed to load episodes. Pull to refresh."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // Initialize with podcast (show) data
    init(podcast: UsersSavedShowsItems) {
        self.podcast = podcast
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = podcast.show.name // Title is the podcast name
        view.backgroundColor = .systemBackground
        setupViews()
        fetchEpisodes()
    }

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(loadingSpinner)
        view.addSubview(errorLabel)
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshEpisodes), for: .valueChanged)
        
        // Loading spinner constraints
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Fetch episodes for the podcast using the show ID
    private func fetchEpisodes() {
        isLoading = true
        errorLabel.isHidden = true
        loadingSpinner.startAnimating()
        
        ChapterApiCaller.shared.getPodcastEpisodes(showID: podcast.show.id ?? "") { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingSpinner.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let episodesResponse):
                    self?.episodes = episodesResponse.episodes ?? [] // Save episodes
                    self?.tableView.reloadData()
                case .failure:
                    self?.showErrorState()
                }
            }
        }
    }

    private func showErrorState() {
        errorLabel.isHidden = false
    }

    @objc private func refreshEpisodes() {
        fetchEpisodes()
    }

    // MARK: - TableView DataSource & Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PodcastEpisodeTableViewCell.identifier, for: indexPath) as? PodcastEpisodeTableViewCell else {
            return UITableViewCell()
        }
        
        let episode = episodes[indexPath.row]
        cell.configure(with: episode)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        let playerVC = PodCastPlayerDetailsViewController(episode: episode)
        present(playerVC, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return episodes.isEmpty ? nil : "Episodes (\(episodes.count))"
    }
}
