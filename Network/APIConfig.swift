//
//  APIConfig.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/16.
//

import Foundation

struct APIConfig {
    static let baseURL = URL(string: "https://api.vimeo.com")!

    static var token: String {
        Bundle.main.object(forInfoDictionaryKey: "VimeoToken") as? String ?? ""
    }
}
