//
//  CreatePlaylistViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 11/01/2025.
//


import UIKit

class CreatePlaylistViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Give your playlist a name"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.text = "My playlist #8"
        textField.textColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 22)
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.green.withAlphaComponent(0.8)
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 8
        button.addTarget(CreatePlaylistViewController.self, action: #selector(didTapCancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.addTarget(CreatePlaylistViewController.self, action: #selector(didTapCreate), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            buttonStack.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCreate() {
        guard let playlistName = nameTextField.text, !playlistName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a playlist name")
            return
        }
        
        // Call createPlaylist with the provided name
        createPlaylist(with: playlistName)
        print("Playlist Created: \(playlistName)")
        
        // Dismiss the modal after creating the playlist
        dismiss(animated: true, completion: nil)
    }

    private func createPlaylist(with name: String) {
        // Call your API to create the playlist
        PlaylistApiCaller.shared.createPlaylist(name: name) { success, playlistID in
            DispatchQueue.main.async {
                if success, let playlistID = playlistID {
                    let playlistNavController = PlayListViewController(playlistID: playlistID)
                    playlistNavController.title = name // Set the playlist name as the title (optional)

                    self.navigationController?.pushViewController(playlistNavController, animated: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    // If playlist creation failed, show an error alert
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to create playlist. Please try again later.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
//    private func createPlaylist(with name: String) {
//        // Call your API to create the playlist
//        PlaylistApiCaller.shared.createPlaylist(name: name) { success in
//            DispatchQueue.main.async {
//                if success {
//                    let playlistNavController = PlayListViewController(playlistID: name) // Use the correct playlist ID here
//                    playlistNavController.title = name // Optionally set the playlist name as the title
//                    
//                    self.navigationController?.pushViewController(playlistNavController, animated: true)
//                    self.dismiss(animated: true, completion: nil)
//                } else {
//                    // Show a failure alert if the playlist creation failed
//                    let alert = UIAlertController(
//                        title: "Error",
//                        message: "Failed to create playlist. Please try again later.",
//                        preferredStyle: .alert
//                    )
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }


    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
