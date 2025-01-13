//
//  CustomActionSheetViewController.swift
//  SpotifyClone
//
//  Created by stephen chacha on 11/01/2025.
//

import UIKit

class CustomActionSheetViewController: UIViewController {
    
    // Define a callback to handle action selections from the action sheet
    var actionHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupActionSheet()
    }
    
    private func setupBackground() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActionSheet() {
        // Container for the action sheet
        let actionSheet = UIView()
        actionSheet.backgroundColor = .black
        actionSheet.layer.cornerRadius = 12
        actionSheet.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionSheet)
        
        NSLayoutConstraint.activate([
            actionSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            actionSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            actionSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        
        // Add Playlist Option
        let playlistButton = createActionButton(
            title: "Playlist",
            subtitle: "Build a playlist with songs or episodes",
            iconName: "music.note.list",
            selector: #selector(didTapPlaylist)
        )
        actionSheet.addSubview(playlistButton)
        
        // Add Blend Option
        let blendButton = createActionButton(
            title: "Blend",
            subtitle: "Combine tastes in a shared playlist with friends",
            iconName: "person.2.wave.2",
            selector: #selector(didSelectBlend)
        )
        actionSheet.addSubview(blendButton)
        
        // Add Cancel Button
        let cancelButton = createCancelButton()
        actionSheet.addSubview(cancelButton)
        
        // Layout
        NSLayoutConstraint.activate([
            playlistButton.topAnchor.constraint(equalTo: actionSheet.topAnchor, constant: 8),
            playlistButton.leadingAnchor.constraint(equalTo: actionSheet.leadingAnchor, constant: 8),
            playlistButton.trailingAnchor.constraint(equalTo: actionSheet.trailingAnchor, constant: -8),
            
            blendButton.topAnchor.constraint(equalTo: playlistButton.bottomAnchor, constant: 8),
            blendButton.leadingAnchor.constraint(equalTo: actionSheet.leadingAnchor, constant: 8),
            blendButton.trailingAnchor.constraint(equalTo: actionSheet.trailingAnchor, constant: -8),
            
            cancelButton.topAnchor.constraint(equalTo: blendButton.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: actionSheet.leadingAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: actionSheet.trailingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: actionSheet.bottomAnchor, constant: -8)
        ])
    }
    
    private func createActionButton(title: String, subtitle: String, iconName: String, selector: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        // Icon
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(icon)
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        // Subtitle Label
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(subtitleLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            icon.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -8)
        ])
        
        return button
    }
    
    private func createCancelButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dismissActionSheet), for: .touchUpInside)
        return button
    }
    
    @objc private func didTapPlaylist() {
        dismiss(animated: true, completion: {
            self.actionHandler?("Create Playlist")
        })
    }
    
    @objc private func didSelectBlend() {
        dismiss(animated: true, completion: {
            self.actionHandler?("Blend")
        })
    }
    
    @objc private func dismissActionSheet() {
        dismiss(animated: true, completion: nil)
    }
}
