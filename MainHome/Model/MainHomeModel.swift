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
    
    var formattedDuration: String? {
        duration?.formattedDuration()
    }
    
    var videoId: String? {
        guard let uri = uri else { return nil }
        let components = uri.split(separator: "/")
        return components.isEmpty ? nil : String(components.last ?? "")
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

