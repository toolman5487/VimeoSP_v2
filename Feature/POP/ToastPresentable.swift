//
//  ToastPresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

protocol ToastPresentable: UIViewController {
    var toastDuration: TimeInterval { get }
    var toastBackgroundColor: UIColor { get }
    var toastTextColor: UIColor { get }
}

extension ToastPresentable {
    
    var toastDuration: TimeInterval { 2.0 }
    var toastBackgroundColor: UIColor { .vimeoBlue }
    var toastTextColor: UIColor { .vimeoWhite }
    
    func showToast(_ message: String, position: ToastPosition = .bottom) {
        let toastView = createToastView(message: message)
        view.addSubview(toastView)
        
        toastView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
            
            switch position {
            case .top:
                make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            case .center:
                make.centerY.equalToSuperview()
            case .bottom:
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            }
        }
        
        toastView.alpha = 0
        toastView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
            toastView.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.alpha = 0
                toastView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    private func createToastView(message: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = toastBackgroundColor
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        let label = UILabel()
        label.text = message
        label.textColor = toastTextColor
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        
        return containerView
    }
}

enum ToastPosition {
    case top
    case center
    case bottom
}

