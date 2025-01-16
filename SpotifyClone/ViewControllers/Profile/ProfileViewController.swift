//
//  ProfileViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Data Properties
    private var topItems: [TopItem] = []
    private var recentlyPlayed: [RecentlyPlayedItem] = []
    private var playlists: [PlaylistItem] = []
    
    private var isTopItemsExpanded = false
    private var isRecentlyPlayedExpanded = false
    private var isPlaylistsExpanded = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        setupUI()
        fetchUserProfile()
        fetchTopItems()
        fetchRecentlyPlayed()
        fetchPlaylists()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(TopItemTableViewCell.self, forCellReuseIdentifier: TopItemTableViewCell.identifier)
        tableView.register(RecentlyPlayedTableViewCell.self, forCellReuseIdentifier: RecentlyPlayedTableViewCell.identifier)
        tableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - API Calls
    
    private func fetchUserProfile() {
        activityIndicator.startAnimating()
        UserApiCaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let userProfile):
                    self?.updateUI(with: userProfile)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func fetchTopItems() {
        UserApiCaller.shared.getUserTopItems(type: "artists") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.topItems = items
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch top items: \(error)")
                }
            }
        }
    }
    
    private func fetchRecentlyPlayed() {
        SpotifyPlayer.shared.getRecentlyPlayed { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.recentlyPlayed = items.items ?? []
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch recently played: \(error)")
                }
            }
        }
    }
    
    private func fetchPlaylists() {
        UserApiCaller.shared.getUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists.items ?? []
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch playlists: \(error)")
                }
            }
        }
    }
    
    // MARK: - UI Updates
    private func updateUI(with profile: UserProfile) {
        nameLabel.text = profile.display_name
        emailLabel.text = profile.country
        
        if let imageUrl = profile.images?.first?.url, let url = URL(string: imageUrl) {
            fetchImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
    }
    
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func signOutTapped(){
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "SignOut", style: .destructive, handler: { _ in
            AuthManager.shared.signOut{ [weak self] signOut in
                if signOut {
                    DispatchQueue.main.async {
                        self?.navigationController?.popToRootViewController(animated: true)
                        let navController = UINavigationController(rootViewController: WelcomeViewController())
                        navController.navigationBar.prefersLargeTitles = true
                        navController.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navController.modalPresentationStyle = .fullScreen
                        self?.present(navController, animated: true,completion: {
                            self?.navigationController?.popViewController(animated: false)
                        })
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    private func signOut(){
        AuthManager.shared.signOut{ [weak self] signOut in
            if signOut {
                DispatchQueue.main.async {
                    self?.navigationController?.popToRootViewController(animated: true)
                    let navController = UINavigationController(rootViewController: WelcomeViewController())
                    navController.navigationBar.prefersLargeTitles = true
                    navController.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                    navController.modalPresentationStyle = .fullScreen
                    self?.present(navController, animated: true,completion: {
                        self?.navigationController?.popViewController(animated: false)
                    })
                }
            }
        }
    }
}

// MARK: - TableView Delegates

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Top Items, Recently Played, Playlists
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isTopItemsExpanded ? topItems.count : min(topItems.count, 4)
        case 1:
            return isRecentlyPlayedExpanded ? recentlyPlayed.count : min(recentlyPlayed.count, 4)
        case 2:
            return isPlaylistsExpanded ? playlists.count : min(playlists.count, 4)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TopItemTableViewCell.identifier, for: indexPath) as! TopItemTableViewCell
            cell.configure(with: topItems[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: RecentlyPlayedTableViewCell.identifier, for: indexPath) as! RecentlyPlayedTableViewCell
            cell.configure(with: recentlyPlayed[indexPath.row])
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistTableViewCell.identifier, for: indexPath) as! PlaylistTableViewCell
            cell.configure(with: playlists[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        
        let seeAllButton = UIButton(type: .system)
        seeAllButton.setTitle("See All", for: .normal)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(seeAllButton)
        
        seeAllButton.tag = section
        seeAllButton.addTarget(self, action: #selector(handleSeeAllTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            
            seeAllButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            seeAllButton.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        
        switch section {
        case 0: titleLabel.text = "Top Items"
        case 1: titleLabel.text = "Recently Played"
        case 2: titleLabel.text = "Playlists"
        default: break
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    @objc private func handleSeeAllTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            isTopItemsExpanded.toggle()
        case 1:
            isRecentlyPlayedExpanded.toggle()
        case 2:
            isPlaylistsExpanded.toggle()
        default:
            break
        }
        tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }
}
