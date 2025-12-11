//
//  LoadingPresentable.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import SnapKit

private struct AssociatedKeys {
    static var loadingIndicator: UInt8 = 0
}

protocol LoadingPresentable: UIViewController {
    var loadingColor: UIColor { get }
}

extension LoadingPresentable {
    
    var loadingColor: UIColor { .vimeoBlue }
    
    private var loadingIndicator: UIActivityIndicatorView {
        if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.loadingIndicator) as? UIActivityIndicatorView {
            return indicator
        }
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = loadingColor
        indicator.hidesWhenStopped = true
        
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        objc_setAssociatedObject(self, &AssociatedKeys.loadingIndicator, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return indicator
    }
    
    func showLoading() {
        view.bringSubviewToFront(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    var isLoadingVisible: Bool {
        loadingIndicator.isAnimating
    }
}

