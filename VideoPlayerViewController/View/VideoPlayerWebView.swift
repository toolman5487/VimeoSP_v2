//
//  VideoPlayerWebView.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import WebKit
import SnapKit

final class VideoPlayerWebView: UIView {
    
    let webView: WKWebView
    
    init(configuration: WKWebViewConfiguration) {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .vimeoWhite
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        self.webView = webView
        
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func evaluateJavaScript(_ script: String, completionHandler: ((Any?, Error?) -> Void)?) {
        webView.evaluateJavaScript(script, completionHandler: completionHandler)
    }
    
    var url: URL? {
        webView.url
    }
}

