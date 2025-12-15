//
//  VideoPlayerViewController.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import UIKit
import WebKit
import SnapKit
import Combine

final class VideoPlayerViewController: UIViewController, LoadingPresentable, BackButtonPresentable, RightBarButtonPresentable {
    
    // MARK: - Properties
    
    var backButtonTopOffset: CGFloat { 16 }
    var backButtonLeadingOffset: CGFloat { 12 }
    var backButtonSize: CGFloat { 32 }
    
    var rightBarButtonTopOffset: CGFloat { 12 }
    var rightBarButtonTrailingOffset: CGFloat { 16 }
    var rightBarButtonSize: CGFloat { 40 }
    
    private let viewModel: VideoPlayerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .vimeoWhite
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        return webView
    }()
    
    private lazy var navigationDelegate = WebViewNavigationDelegate(
        onLoadingChange: { [weak self] isLoading in
            self?.viewModel.isLoading = isLoading
        },
        onPageLoad: { [weak self] in
            self?.handlePageLoaded()
        },
        shouldAllowNavigation: { [weak self] url in
            self?.viewModel.isAllowedURL(url) ?? false
        }
    )
    
    
    // MARK: - Initialization
    
    init(videoURL: String) {
        self.viewModel = VideoPlayerViewModel(videoURL: videoURL)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackButton()
        setupRightBarButton()
        setupBindings()
        loadVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .vimeoWhite
        
        view.addSubview(webView)
        
        viewModel.setupAuthenticationCookies(webView: webView)
        
        if let userScript = viewModel.createAuthenticationUserScript() {
            webView.configuration.userContentController.addUserScript(userScript)
        }
        
        webView.navigationDelegate = navigationDelegate
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.right.left.bottom.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.showLoading() : self?.hideLoading()
            }
            .store(in: &cancellables)
        
        viewModel.$shouldRedirectToLogin
            .receive(on: DispatchQueue.main)
            .compactMap { $0 ? () : nil }
            .sink { [weak self] _ in
                self?.redirectToLogin()
            }
            .store(in: &cancellables)
        
        viewModel.$shouldReloadOriginalURL
            .receive(on: DispatchQueue.main)
            .compactMap { $0 ? () : nil }
            .sink { [weak self] _ in
                self?.reloadOriginalVideo()
                self?.viewModel.markReloadCompleted()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    private func loadVideo() {
        guard let request = viewModel.getAuthenticatedRequest() else { return }
        webView.load(request)
    }
    
    private func handlePageLoaded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        let script = viewModel.getLoginCheckScript()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.webView.evaluateJavaScript(script) { [weak self] result, _ in
                guard let self = self, let result = result else { return }
                let currentURL = self.webView.url?.absoluteString
                self.viewModel.updateLoginStatus(result, currentURL: currentURL)
            }
        }
    }
    
    private func redirectToLogin() {
        guard let loginURL = viewModel.getLoginURL() else { return }
        webView.load(URLRequest(url: loginURL))
    }
    
    private func reloadOriginalVideo() {
        guard let request = viewModel.getOriginalVideoRequest() else { return }
        webView.load(request)
    }
}

private final class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    
    private let onLoadingChange: (Bool) -> Void
    private let onPageLoad: () -> Void
    private let shouldAllowNavigation: (URL) -> Bool
    
    init(
        onLoadingChange: @escaping (Bool) -> Void,
        onPageLoad: @escaping () -> Void,
        shouldAllowNavigation: @escaping (URL) -> Bool
    ) {
        self.onLoadingChange = onLoadingChange
        self.onPageLoad = onPageLoad
        self.shouldAllowNavigation = shouldAllowNavigation
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if shouldAllowNavigation(url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onLoadingChange(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoadingChange(false)
        onPageLoad()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onLoadingChange(false)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onLoadingChange(false)
    }
}

