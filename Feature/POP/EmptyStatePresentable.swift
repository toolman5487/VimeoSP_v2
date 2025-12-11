//
//  EmptyStatePresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

private struct AssociatedKeys {
    static var emptyStateView: UInt8 = 0
    static var emptyStateLabel: UInt8 = 0
}

protocol EmptyStatePresentable: UIViewController {
    var emptyStateInset: CGFloat { get }
    var emptyStateTextColor: UIColor { get }
}

extension EmptyStatePresentable {
    
    var emptyStateInset: CGFloat { 40 }
    var emptyStateTextColor: UIColor { .vimeoWhite.withAlphaComponent(0.6) }
    
    private var emptyStateView: UIView {
        if let emptyView = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? UIView {
            return emptyView
        }
        
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        emptyView.isHidden = true
        emptyView.isAccessibilityElement = true
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(emptyStateInset)
        }
        
        emptyView.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, emptyView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return emptyView
    }
    
    private var emptyStateLabel: UILabel {
        if let label = objc_getAssociatedObject(self, &AssociatedKeys.emptyStateLabel) as? UILabel {
            return label
        }
        
        let label = UILabel()
        label.textColor = emptyStateTextColor
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        
        objc_setAssociatedObject(self, &AssociatedKeys.emptyStateLabel, label, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return label
    }
    
    func showEmptyState(message: String) {
        emptyStateLabel.text = message
        emptyStateView.accessibilityLabel = message
        emptyStateView.isHidden = false
        view.bringSubviewToFront(emptyStateView)
    }
    
    func hideEmptyState() {
        emptyStateView.isHidden = true
    }
    
    var isEmptyStateVisible: Bool {
        !emptyStateView.isHidden
    }
}

