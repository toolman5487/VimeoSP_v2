//
//  URLConfig.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation

// MARK: - Configuration

struct URLConfig {
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.vimeo.com") else {
            fatalError("Invalid base URL configuration")
        }
        return url
    }()
    
    static let frontendBaseURL: URL = {
        guard let url = URL(string: "https://vimeo.com") else {
            fatalError("Invalid frontend base URL configuration")
        }
        return url
    }()

    static var token: String {
        Bundle.main.object(forInfoDictionaryKey: "VimeoToken") as? String ?? ""
    }
}

// MARK: - Me Paths

enum MePath {
    case me
    case meVideos
    case meLikes
    case meFollowing
    case meFollowers
    case meAlbums
    case mePictures
    case meFeed
    case meChannels
    case meGroups
    case meTeams
    case meWatchHistory

    var path: String {
        switch self {
        case .me: return "/me"
        case .meVideos: return "/me/videos"
        case .meLikes: return "/me/likes"
        case .meFollowing: return "/me/following"
        case .meFollowers: return "/me/followers"
        case .meAlbums: return "/me/albums"
        case .mePictures: return "/me/pictures"
        case .meFeed: return "/me/feed"
        case .meChannels: return "/me/channels"
        case .meGroups: return "/me/groups"
        case .meTeams: return "/me/teams"
        case .meWatchHistory: return "/me/watched/videos"
        }
    }
    
    var url: URL {
        URLConfig.baseURL.appendingPathComponent(path)
    }
}

// MARK: - Search Paths

enum SearchPath {
    case videos
    case users
    case channels
    case groups
    
    var path: String {
        switch self {
        case .videos: return "/videos"
        case .users: return "/users"
        case .channels: return "/channels"
        case .groups: return "/groups"
        }
    }
    
    var url: URL {
        URLConfig.baseURL.appendingPathComponent(path)
    }
}

// MARK: - Video Paths

enum VideoPath {
    case video(videoId: String)
    case videoFiles(videoId: String)
    case videoRelated(videoId: String)
    case videoComments(videoId: String)
    case videoLikes(videoId: String)
    
    var path: String {
        switch self {
        case .video(let videoId):
            return "/videos/\(videoId)"
        case .videoFiles(let videoId):
            return "/videos/\(videoId)/files"
        case .videoRelated(let videoId):
            return "/videos/\(videoId)/related"
        case .videoComments(let videoId):
            return "/videos/\(videoId)/comments"
        case .videoLikes(let videoId):
            return "/videos/\(videoId)/likes"
        }
    }
    
    var url: URL {
        URLConfig.baseURL.appendingPathComponent(path)
    }
}
