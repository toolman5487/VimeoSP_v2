//
//  KeyboardDismissable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var tapGesture: UInt8 = 0
}

protocol KeyboardDismissable: UIViewController {}

extension KeyboardDismissable {
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        objc_setAssociatedObject(self, &AssociatedKeys.tapGesture, tapGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension UIViewController {
    @objc func dismissKeyboardAction() {
        view.endEditing(true)
    }
}

