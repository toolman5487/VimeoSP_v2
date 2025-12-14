//
//  BackButtonPresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

private struct AssociatedKeys {
    static var backButton: UInt8 = 0
}

protocol BackButtonPresentable: UIViewController {
    var backButtonColor: UIColor { get }
    var backButtonBackgroundAlpha: CGFloat { get }
    var backButtonTopOffset: CGFloat { get }
    var backButtonLeadingOffset: CGFloat { get }
    var backButtonSize: CGFloat { get }
}

extension BackButtonPresentable {
    
    var backButtonColor: UIColor { .vimeoBlack }
    var backButtonBackgroundAlpha: CGFloat { 1 }
    var backButtonTopOffset: CGFloat { 0 }
    var backButtonLeadingOffset: CGFloat { 0 }
    var backButtonSize: CGFloat { 40 }
    
    private var backButton: UIButton {
        if let button = objc_getAssociatedObject(self, &AssociatedKeys.backButton) as? UIButton {
            return button
        }
        
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        config.image = UIImage(systemName: "chevron.left", withConfiguration: imageConfig)
        config.baseForegroundColor = backButtonColor
        config.background.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(backButtonBackgroundAlpha)
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.isHidden = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.handleBackButtonTapped()
        }, for: .touchUpInside)
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(backButtonTopOffset)
            make.leading.equalToSuperview().offset(backButtonLeadingOffset)
            make.width.height.equalTo(backButtonSize)
        }
        
        button.layer.zPosition = 1000
        
        objc_setAssociatedObject(self, &AssociatedKeys.backButton, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return button
    }
    
    func setupBackButton() {
        _ = backButton
    }
    
    func showBackButton(animated: Bool = true) {
        let button = backButton
        button.isHidden = false
        view.bringSubviewToFront(button)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                button.alpha = 1
            }
        } else {
            button.alpha = 1
        }
    }
    
    func hideBackButton(animated: Bool = true) {
        let button = backButton
        if animated {
            UIView.animate(withDuration: 0.3) {
                button.alpha = 0
            } completion: { _ in
                button.isHidden = true
            }
        } else {
            button.alpha = 0
            button.isHidden = true
        }
    }
    
    func handleBackButtonTapped() {
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

