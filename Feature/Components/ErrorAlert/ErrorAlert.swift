//
//  ErrorAlert.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/9.
//

import Foundation
import UIKit

enum ErrorAlert {
    
    static func show(
        from viewController: UIViewController,
        error: Error,
        title: String = "Error",
        retryAction: (() -> Void)? = nil
    ) {
        let message: String
        if let apiError = error as? APIError {
            message = apiError.localizedDescription
        } else {
            message = error.localizedDescription
        }
        
        showAlert(from: viewController, title: title, message: message, retryAction: retryAction)
    }
    
    static func show(
        from viewController: UIViewController,
        errorMessage: String?,
        title: String = "Error",
        retryAction: (() -> Void)? = nil
    ) {
        guard let message = errorMessage, !message.isEmpty else { return }
        showAlert(from: viewController, title: title, message: message, retryAction: retryAction)
    }
    
    private static func showAlert(
        from viewController: UIViewController,
        title: String,
        message: String,
        retryAction: (() -> Void)?
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        if let retryAction = retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                retryAction()
            })
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController.present(alert, animated: true)
    }
}
