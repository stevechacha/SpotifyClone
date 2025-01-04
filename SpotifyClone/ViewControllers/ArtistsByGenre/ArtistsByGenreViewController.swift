//
//  ArtistsByGenreViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/01/2025.
//

import UIKit

class ArtistsByGenreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var genre: String = ""
    var artists: [TopItem] = []
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = genre
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArtistCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath)
        let artist = artists[indexPath.row]
        cell.textLabel?.text = artist.name
        return cell
    }
    
    // Handle artist selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Implement navigation to artist detail if needed
    }
}
