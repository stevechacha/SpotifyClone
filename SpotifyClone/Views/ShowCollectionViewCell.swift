//
//  ShowCollectionViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 06/12/2024.
//


import UIKit
import SDWebImage

class ShowCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ShowCollectionViewCell"
 
    
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 5, y: 5, width: contentView.bounds.width - 10, height: contentView.bounds.height - 35)
        nameLabel.frame = CGRect(x: 5, y: contentView.bounds.height - 30, width: contentView.bounds.width - 10, height: 25)
    }
    
    func configure(with show: UsersSavedShowsItems) {
        nameLabel.text = show.show.name
        
        // Use SDWebImage to load the image
        if let imageUrl = show.show.images?.first?.url {
            imageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholder")) { [weak self] image, error, _, _ in
                if let error = error {
                    print("Failed to load image: \(error.localizedDescription)")
                } else {
                    print("Image loaded successfully for: \(self?.nameLabel.text ?? "")")
                }
            }
        }
    }
}
