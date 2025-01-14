//
//  AlbumCoverCollectionViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 13/01/2025.
//


protocol AlbumCoverGridCollectionViewCellDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: AlbumCoverGridCollectionViewCell)
}



// AlbumCoverCollectionViewCell.swift
import UIKit

class AlbumCoverGridCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumCoverGridCollectionViewCell"
    
    weak var delegate: AlbumCoverGridCollectionViewCellDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playAllButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        let image = UIImage(
            systemName: "play.fill" ,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30,weight: .regular)
        )
        button.setImage(image,for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        
        playAllButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    @objc private func didTapPlayAll(){
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = height/1.8
        imageView.frame = CGRect(x: (width - imageSize), y: 20, width: imageSize, height: imageSize)
        
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 44)
        
        playAllButton.frame = CGRect(x: width - 90, y: height-90, width: 50, height: 50)
        
    }
    
    func configure(with viewModel: AlbumCoverCollectionViewModel){
        nameLabel.text = viewModel.playlistName
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        
        imageView.sd_setImage(with: viewModel.artUrl, completed: nil)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
