//
//  VideoPlayerViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import Combine
import WebKit

final class VideoPlayerViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    
    @Published private(set) var videoURL: String
    @Published private(set) var isLoggedIn: Bool = false
    @Published var shouldRedirectToLogin: Bool = false
    @Published var shouldReloadOriginalURL: Bool = false
    
    private var originalVideoURL: String
    
    // MARK: - Private Properties
    
    // MARK: - Initialization
    
    init(videoURL: String) {
        self.videoURL = videoURL
        self.originalVideoURL = videoURL
        super.init()
    }
    
    // MARK: - Public Methods
    
    func getAuthenticatedRequest() -> URLRequest? {
        guard let url = URL(string: videoURL) else { return nil }
        
        var request = URLRequest(url: url)
        let token = URLConfig.token
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        return request
    }
    
    func setupAuthenticationCookies(webView: WKWebView) {
        let token = URLConfig.token
        guard !token.isEmpty else {
            return
        }
        
        let cookieNames = ["access_token", "token", "vimeo_token", "oauth_token", "auth_token"]
        
        for cookieName in cookieNames {
            let cookieProperties: [HTTPCookiePropertyKey: Any] = [
                .domain: ".vimeo.com",
                .path: "/",
                .name: cookieName,
                .value: token,
                .secure: "true",
                .expires: Date(timeIntervalSinceNow: 86400 * 30)
            ]
            
            if let cookie = HTTPCookie(properties: cookieProperties) {
                let dataStore = webView.configuration.websiteDataStore.httpCookieStore
                dataStore.setCookie(cookie)
            }
        }
    }
    
    func createAuthenticationUserScript() -> WKUserScript? {
        let token = URLConfig.token
        guard !token.isEmpty else { return nil }
        
        let escapedToken = token.replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\\", with: "\\\\")
        
        let scriptSource = """
        (function() {
            const token = '\(escapedToken)';
            
            try {
                localStorage.setItem('vimeo_access_token', token);
                localStorage.setItem('access_token', token);
                sessionStorage.setItem('vimeo_access_token', token);
            } catch(e) {}
            
            const originalFetch = window.fetch;
            window.fetch = function(...args) {
                if (args[1]) {
                    args[1].headers = args[1].headers || {};
                    if (!args[1].headers['Authorization']) {
                        args[1].headers['Authorization'] = 'Bearer ' + token;
                    }
                } else if (args[0] && typeof args[0] === 'string') {
                    args[1] = {
                        headers: {
                            'Authorization': 'Bearer ' + token
                        }
                    };
                }
                return originalFetch.apply(this, args);
            };
            
            const originalOpen = XMLHttpRequest.prototype.open;
            XMLHttpRequest.prototype.open = function(method, url, ...rest) {
                this.addEventListener('loadstart', function() {
                    this.setRequestHeader('Authorization', 'Bearer ' + token);
                });
                return originalOpen.apply(this, [method, url, ...rest]);
            };
            
            document.addEventListener('error', function(e) {
                if (e.target && e.target.tagName === 'IMG') {
                    e.preventDefault();
                    e.stopPropagation();
                }
            }, true);
            
            const images = document.querySelectorAll('img');
            images.forEach(function(img) {
                img.addEventListener('error', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                });
            });
        })();
        """
        
        return WKUserScript(
            source: scriptSource,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
    
    func getLoginCheckScript() -> String {
        return """
        (function() {
            const indicators = [
                document.querySelector('[data-account-menu]'),
                document.querySelector('[aria-label*="Account"]'),
                document.querySelector('[aria-label*="Profile"]'),
                document.querySelector('.js-user-menu'),
                document.querySelector('a[href*="/user/"]'),
                document.querySelector('[data-user-id]'),
                document.querySelector('img[alt*="profile"]'),
                document.querySelector('img[alt*="avatar"]'),
                document.querySelector('button[aria-label*="Account"]'),
                document.querySelector('div[class*="user-menu"]'),
                document.querySelector('a[href*="/settings"]')
            ];
            
            const isLoggedIn = indicators.some(el => el !== null);
            
            if (!isLoggedIn && !window.location.href.includes('/log_in')) {
                const loginLinks = Array.from(document.querySelectorAll('a')).filter(link => {
                    const href = (link.href || '').toLowerCase();
                    const text = (link.textContent || '').toLowerCase();
                    return href.includes('/log_in') || href.includes('/login') || 
                           text.includes('log in') || text.includes('sign in');
                });
                
                if (loginLinks.length > 0) {
                    return 'redirect_to_login';
                }
            }
            
            return isLoggedIn;
        })();
        """
    }
    
    func updateLoginStatus(_ result: Any, currentURL: String?) {
        if let isLoggedIn = result as? NSNumber {
            let wasLoggedIn = self.isLoggedIn
            self.isLoggedIn = isLoggedIn.boolValue
            
            if isLoggedIn.boolValue && !wasLoggedIn {
                if let currentURL = currentURL, currentURL.contains("/log_in") {
                    self.shouldReloadOriginalURL = true
                }
            }
        } else if let status = result as? String, status == "redirect_to_login" {
            if let currentURL = currentURL, !currentURL.contains("/log_in") {
                self.shouldRedirectToLogin = true
            }
        }
    }
    
    func getLoginURL() -> URL? {
        return URL(string: "https://vimeo.com/log_in")
    }
    
    func getOriginalVideoRequest() -> URLRequest? {
        guard let url = URL(string: originalVideoURL) else { return nil }
        
        var request = URLRequest(url: url)
        let token = URLConfig.token
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        return request
    }
    
    func isAllowedURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString
        
        // 允許原視頻 URL
        if urlString == videoURL || urlString == originalVideoURL {
            return true
        }
        
        // 允許登入頁面
        if urlString.contains("vimeo.com/log_in") || urlString.contains("vimeo.com/login") {
            return true
        }
        
        // 只允許同一個視頻頁面的各種路徑變化（如加上查詢參數）
        if let videoURLObj = URL(string: videoURL),
           let originalURLObj = URL(string: originalVideoURL) {
            
            let videoHost = videoURLObj.host
            let urlHost = url.host
            
            if videoHost == urlHost || originalURLObj.host == urlHost {
                // 如果是同一個視頻 ID，允許
                if let videoPath = videoURLObj.pathComponents.last,
                   let urlPath = url.pathComponents.last,
                   videoPath == urlPath {
                    return true
                }
            }
        }
        
        return false
    }
}
