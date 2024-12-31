//
//  PodCastPlayerDetailsViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit
import AVFoundation

class PodCastPlayerDetailsViewController: UIViewController {
    private let episode: Episode
    private var player: AVPlayer?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        return button
    }()

    private let slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        return slider
    }()



    init(episode: Episode) {
        self.episode = episode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Now Playing"
        view.backgroundColor = .systemBackground
        setupUI()
        setupPlayer()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(playPauseButton)
        view.addSubview(slider)

        titleLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 60)
        playPauseButton.frame = CGRect(x: (view.frame.width - 100) / 2, y: 200, width: 100, height: 50)
        slider.frame = CGRect(x: 20, y: 300, width: view.frame.width - 40, height: 30)

        titleLabel.text = episode.name
    }

    private func setupPlayer() {
        guard let audioURL = URL(string: episode.audioPreviewURL ?? "") else { return } // Assuming `audioUrl` is a property of `Episode`
        player = AVPlayer(url: audioURL)
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration.seconds else { return }
            self.slider.value = Float(time.seconds / duration)
        }
    }

    @objc private func didTapPlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
        } else {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
        }
    }

    @objc private func didSlideSlider(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration.seconds else { return }
        let newTime = Double(sender.value) * duration
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
}
