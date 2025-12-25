//
//  MainHomeModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation

// MARK: - Main Home Video List Response

struct MainHomeVideoListResponse: Codable {
    let total: Int?
    let page: Int?
    let perPage: Int?
    let paging: Paging?
    let data: [MainHomeVideo]?
    
    enum CodingKeys: String, CodingKey {
        case total, page
        case perPage = "per_page"
        case paging, data
    }
}

// MARK: - Main Home Video

struct MainHomeVideo: Codable {
    let uri: String?
    let name: String?
    let description: String?
    let type: String?
    let duration: Int?
    let createdTime: String?
    let pictures: VimeoPictures?
    let stats: VimeoStats?
    let user: VimeoUser?
    let privacy: VimeoPrivacy?
    
    enum CodingKeys: String, CodingKey {
        case uri, name, description, type, duration
        case createdTime = "created_time"
        case pictures, stats, user, privacy
    }
    
    private static var durationCache: [Int: String] = [:]
    private static var videoIdCache: [String: String] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.vimeo.video.cache", attributes: .concurrent)
    
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        return Self.cacheQueue.sync {
            if let cached = Self.durationCache[duration] {
                return cached
            }
            let formatted = duration.formattedDuration()
            Self.durationCache[duration] = formatted
            return formatted
        }
    }
    
    var videoId: String? {
        guard let uri = uri else { return nil }
        return Self.cacheQueue.sync {
            if let cached = Self.videoIdCache[uri] {
                return cached
            }
            let components = uri.split(separator: "/")
            let id = components.isEmpty ? nil : String(components.last ?? "")
            if let id = id {
                Self.videoIdCache[uri] = id
            }
            return id
        }
    }
    
    var thumbnailURL: String? {
        pictures?.mediumPictureURL
    }
    
    var formattedStats: String? {
        stats?.formattedPlays
    }
}

// MARK: - Video Sort Type

enum VideoSortType: String, CaseIterable {
    case popular = "popular"
    case trending = "trending"
    case date = "date"
    case alphabetical = "alphabetical"
    
    var displayName: String {
        switch self {
        case .popular: return "Popular"
        case .trending: return "Trending"
        case .date: return "Latest"
        case .alphabetical: return "Alphabetical"
        }
    }
}

