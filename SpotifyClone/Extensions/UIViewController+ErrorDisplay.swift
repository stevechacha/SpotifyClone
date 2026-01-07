//
//  UIViewController+ErrorDisplay.swift
//  SpotifyClone
//
//  Created for error display utilities
//

import UIKit

extension UIViewController {
    /// Display an error alert with user-friendly message
    func showError(_ error: Error, title: String = "Error", completion: (() -> Void)? = nil) {
        let message: String
        let recoveryAction: String?
        
        if let apiError = error as? ApiError {
            message = apiError.userMessage
            recoveryAction = apiError.recoveryAction
        } else {
            message = error.localizedDescription
            recoveryAction = nil
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let recoveryAction = recoveryAction {
            alert.addAction(UIAlertAction(title: recoveryAction, style: .default) { _ in
                completion?()
            })
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
        }
        
        present(alert, animated: true)
    }
    
    /// Display a success message
    func showSuccess(_ message: String, title: String = "Success") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

