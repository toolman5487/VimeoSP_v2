//
//  VideoPlayerView.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import UIKit
import WebKit
import SnapKit

final class VideoPlayerView: UIView {
    
    private enum Constants {
        static let aspectRatio: CGFloat = 16.0 / 9.0
        static let webViewHeight: CGFloat = UIScreen.main.bounds.width / aspectRatio
    }
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        return webView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .vimeoBlue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .black
        
        addSubview(placeholderImageView)
        addSubview(webView)
        addSubview(loadingIndicator)
        
        placeholderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Constants.webViewHeight)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(videoId: String, thumbnailURL: String?) {
        loadThumbnail(thumbnailURL)
        loadVideo(videoId: videoId)
    }
    
    private func loadThumbnail(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            placeholderImageView.image = nil
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.placeholderImageView.image = image
            }
        }.resume()
    }
    
    private func loadVideo(videoId: String) {
        guard let embedURL = URL(string: "https://player.vimeo.com/video/\(videoId)?autoplay=1&muted=0") else { return }
        
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; background: #000; }
                iframe { width: 100%; height: 100%; border: 0; }
            </style>
        </head>
        <body>
            <iframe src="\(embedURL.absoluteString)" 
                    frameborder="0" 
                    allow="autoplay; fullscreen; picture-in-picture" 
                    allowfullscreen>
            </iframe>
        </body>
        </html>
        """
        
        loadingIndicator.startAnimating()
        webView.loadHTMLString(embedHTML, baseURL: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.placeholderImageView.isHidden = true
        }
    }
    
    func pause() {
        webView.evaluateJavaScript("document.querySelector('iframe')?.contentWindow.postMessage('pause', '*')", completionHandler: nil)
    }
    
    func play() {
        webView.evaluateJavaScript("document.querySelector('iframe')?.contentWindow.postMessage('play', '*')", completionHandler: nil)
    }
}

