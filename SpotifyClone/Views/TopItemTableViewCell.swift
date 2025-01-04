//
//  TopItemTableViewCell.swift
//  SpotifyClone
//
//  Created by stephen chacha on 03/01/2025.
//


import UIKit

class TopItemTableViewCell: UITableViewCell {
    static let identifier = "TopItemTableViewCell"
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(genresLabel)
        
        NSLayoutConstraint.activate([
            // Image
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Type Label
            typeLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // Genres Label
            genresLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 10),
            genresLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            genresLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with topItem: TopItem) {
        nameLabel.text = topItem.name
        typeLabel.text = "Type: \(topItem.type?.capitalized ?? "Unknown")"
        genresLabel.text = topItem.genres?.joined(separator: ", ") ?? "No genres available"
        
        if let imageUrl = topItem.images?.first?.url {
            loadImage(from: imageUrl)
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
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.itemImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
