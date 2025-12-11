//
//  AlertPresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/9.
//

import Foundation
import UIKit

protocol AlertPresentable: UIViewController {}

extension AlertPresentable {
    
    func showError(
        _ error: Error,
        title: String = "Error",
        retryAction: (() -> Void)? = nil
    ) {
        ErrorAlert.show(
            from: self,
            error: error,
            title: title,
            retryAction: retryAction
        )
    }
    
    func showError(
        message: String?,
        title: String = "Error",
        retryAction: (() -> Void)? = nil
    ) {
        ErrorAlert.show(
            from: self,
            errorMessage: message,
            title: title,
            retryAction: retryAction
        )
    }
}

