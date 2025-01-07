//
//  EpisodeDetailViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//


import UIKit

class UserEpisodeDetailViewController: UIViewController {
    private let episode: UserSavedEpisode
    private let chapterApiCaller = ChapterApiCaller.shared

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Episode", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(UserEpisodeDetailViewController.self, action: #selector(didTapPlay), for: .touchUpInside)
        return button
    }()

    init(episode: UserSavedEpisode) {
        self.episode = episode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode Details"
        view.backgroundColor = .systemBackground
        setupUI()
        configure(with: episode)
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(playButton)

        scrollView.frame = view.bounds
        let padding: CGFloat = 20
        titleLabel.frame = CGRect(x: padding, y: padding, width: view.frame.width - 2 * padding, height: 80)
        descriptionLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 10, width: view.frame.width - 2 * padding, height: 200)
        playButton.frame = CGRect(x: padding, y: descriptionLabel.frame.maxY + 20, width: view.frame.width - 2 * padding, height: 50)
    }

    private func configure(with episode: UserSavedEpisode) {
        titleLabel.text = episode.episode?.name
        descriptionLabel.text = episode.episode?.description ?? "No description available."
    }

    @objc private func didTapPlay() {
        let playerVC = EpisodePlayerDetailsViewController(episode: episode)
        present(playerVC, animated: true)
    }
}
