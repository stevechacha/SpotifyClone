//
//  ProfileViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 04/12/2024.
//

import UIKit


class ProfileViewController: UIViewController {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 // Rounded image
        imageView.backgroundColor = .lightGray // Placeholder background
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    private let subscriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.numberOfLines = 1
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        setupUI()
        fetchUserProfile()
        
    }
    
    
    

    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(countryLabel)
        view.addSubview(subscriptionLabel)
        view.addSubview(activityIndicator)
        
        // Layout UI Components
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        subscriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Country Label
            countryLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            countryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subscription Label
            subscriptionLabel.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 8),
            subscriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subscriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    // MARK: - Fetch User Profile
    private func fetchUserProfile() {
        activityIndicator.startAnimating()
        
        UserApiCaller.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let userProfile):
                    UserApiCaller.shared.getUserProfile(userID: userProfile.id) { userProfile in
                        switch userProfile {
                        case .success(let success):
                            print(success)
                        case .failure(let failure):
                            print(failure)
                        }
                    }
                    self?.updateUI(with: userProfile)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    // MARK: - Update UI
    private func updateUI(with profile: UserProfile) {
        nameLabel.text = profile.display_name
        emailLabel.text = profile.email
        countryLabel.text = "Country: \(profile.country ?? "")"
        subscriptionLabel.text = "Subscription: \(profile.product?.capitalized ?? "")"
        
        if let imageUrl = profile.images?.first?.url, let url = URL(string: imageUrl) {
            fetchImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.profileImageView.image = image ?? UIImage(systemName: "person.crop.circle")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(systemName: "person.crop.circle")
            }
        }
    }
    
    // MARK: - Fetch Profile Image
    private func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image) // Ensure completion handler runs on the main thread
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil) // Ensure completion handler runs on the main thread
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Show Error
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func getTopUserItem() {
        UserApiCaller.shared.getUserTopItems(type: "tracks") { results in
            switch results {
            case .success(let success):
                break
            case .failure(let failure):
                break
            }
            
        }
    }
    

}

