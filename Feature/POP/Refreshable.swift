//
//  Refreshable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var refreshControl: UInt8 = 0
}

protocol Refreshable: UIViewController {
    var refreshTintColor: UIColor { get }
    func handleRefresh()
}

extension Refreshable {
    
    var refreshTintColor: UIColor { .vimeoWhite }
    
    var refreshControl: UIRefreshControl {
        if let control = objc_getAssociatedObject(self, &AssociatedKeys.refreshControl) as? UIRefreshControl {
            return control
        }
        
        let control = UIRefreshControl()
        control.tintColor = refreshTintColor
        
        let action = UIAction { [weak self] _ in
            self?.handleRefresh()
        }
        control.addAction(action, for: .valueChanged)
        
        objc_setAssociatedObject(self, &AssociatedKeys.refreshControl, control, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return control
    }
    
    func setupRefresh(for scrollView: UIScrollView) {
        scrollView.refreshControl = refreshControl
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    var isRefreshing: Bool {
        refreshControl.isRefreshing
    }
}

