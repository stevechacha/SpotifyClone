//
//  PodcastEpisodeTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 31/12/2024.
//

import UIKit

class PodcastEpisodeTableViewCell: UITableViewCell {
    static let identifier = "PodcastEpisodeTableViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(durationLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 10, y: 5, width: contentView.frame.width - 20, height: 40)
        durationLabel.frame = CGRect(x: 10, y: 50, width: contentView.frame.width - 20, height: 20)
    }

    func configure(with episode: Episode) {
        titleLabel.text = episode.name
        durationLabel.text = "Duration: \(episode.durationMs) mins" // Assuming `durationInMinutes` is available
    }
}
