//
//  RightBarButtonPresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

private struct AssociatedKeys {
    static var rightBarButton: UInt8 = 0
}

protocol RightBarButtonPresentable: UIViewController {
    var rightBarButtonIcon: String? { get }
    var rightBarButtonColor: UIColor { get }
    var rightBarButtonBackgroundAlpha: CGFloat { get }
    var rightBarButtonTopOffset: CGFloat { get }
    var rightBarButtonTrailingOffset: CGFloat { get }
    var rightBarButtonSize: CGFloat { get }
}

extension RightBarButtonPresentable {
    
    var rightBarButtonIcon: String? { nil }
    var rightBarButtonColor: UIColor { .vimeoBlack }
    var rightBarButtonBackgroundAlpha: CGFloat { 1 }
    var rightBarButtonTopOffset: CGFloat { 0 }
    var rightBarButtonTrailingOffset: CGFloat { 0 }
    var rightBarButtonSize: CGFloat { 40 }
    
    private var rightBarButton: UIButton {
        if let button = objc_getAssociatedObject(self, &AssociatedKeys.rightBarButton) as? UIButton {
            return button
        }
        
        var config = UIButton.Configuration.plain()
        
        if let iconName = rightBarButtonIcon {
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
            config.image = UIImage(systemName: iconName, withConfiguration: imageConfig)
        }
        
        config.baseForegroundColor = rightBarButtonColor
        config.background.backgroundColor = UIColor.vimeoWhite.withAlphaComponent(rightBarButtonBackgroundAlpha)
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.handleRightBarButtonTapped()
        }, for: .touchUpInside)
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(rightBarButtonTopOffset)
            make.trailing.equalToSuperview().offset(-rightBarButtonTrailingOffset)
            make.width.height.equalTo(rightBarButtonSize)
        }
        
        button.layer.zPosition = 1000
        
        objc_setAssociatedObject(self, &AssociatedKeys.rightBarButton, button, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return button
    }
    
    func setupRightBarButton() {
        let button = rightBarButton
        view.bringSubviewToFront(button)
    }
    
    func handleRightBarButtonTapped() {
        
    }
}

