//
//  GenreCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/01/2025.
//

import UIKit

class GenreCell: UICollectionViewCell {
    static let identifier = "GenreCell"

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let artistCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(genreLabel)
        contentView.addSubview(artistCountLabel)
        contentView.clipsToBounds = true

        
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        artistCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            artistCountLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 5),
            artistCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            artistCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            artistCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with genre: String, artistCount: Int) {
        genreLabel.text = genre.capitalized
        artistCountLabel.text = "\(artistCount) artists"
    }
}
