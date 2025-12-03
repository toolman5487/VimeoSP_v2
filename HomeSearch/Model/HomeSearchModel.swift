//
//  HomeSearchModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation

// MARK: - Root Search Response
struct VimeoSearchResponse: Codable {
    let total: Int?
    let page: Int?
    let perPage: Int?
    let paging: Paging?
    let data: [VimeoVideo]?
    
    enum CodingKeys: String, CodingKey {
        case total, page
        case perPage = "per_page"
        case paging, data
    }
}

// MARK: - Paging
struct Paging: Codable {
    let next: String?
    let previous: String?
    let first: String?
    let last: String?
}

// MARK: - Video
struct VimeoVideo: Codable {
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
    let files: [VimeoFile]?
    
    enum CodingKeys: String, CodingKey {
        case uri, name, description, type, duration
        case createdTime = "created_time"
        case pictures, stats, user, privacy, files
    }
    
    var formattedDuration: String? {
        guard let duration = duration, duration > 0 else { return nil }
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - User
struct VimeoUser: Codable {
    let uri: String?
    let name: String?
    let link: String?
    let pictures: VimeoPictures?
}

// MARK: - Pictures (Thumbnails)
struct VimeoPictures: Codable {
    let uri: String?
    let active: Bool?
    let type: String?
    let baseLink: String?
    let sizes: [VimeoPictureSize]?
    
    enum CodingKeys: String, CodingKey {
        case uri, active, type
        case baseLink = "base_link"
        case sizes
    }
    
    var largestPictureURL: String? {
        guard let sizes = sizes, !sizes.isEmpty else { return nil }
        var largest = sizes[0]
        for size in sizes {
            let currentArea = (largest.width ?? 0) * (largest.height ?? 0)
            let newArea = (size.width ?? 0) * (size.height ?? 0)
            if newArea > currentArea {
                largest = size
            }
        }
        return largest.link
    }
    
    var mediumPictureURL: String? {
        guard let sizes = sizes, !sizes.isEmpty else { return nil }
        var closest = sizes[0]
        var minDiff = abs((sizes[0].width ?? 640) - 640)
        for size in sizes {
            guard let width = size.width else { continue }
            let diff = abs(width - 640)
            if diff < minDiff {
                minDiff = diff
                closest = size
            }
        }
        return closest.link
    }
}

// MARK: - Picture Size
struct VimeoPictureSize: Codable {
    let width: Int?
    let height: Int?
    let link: String?
}

// MARK: - Stats
struct VimeoStats: Codable {
    let plays: Int?
    
    var formattedPlays: String? {
        guard let plays = plays else { return nil }
        if plays >= 1_000_000 {
            return String(format: "%.1fM", Double(plays) / 1_000_000.0)
        } else if plays >= 1_000 {
            return String(format: "%.1fK", Double(plays) / 1_000.0)
        } else {
            return "\(plays)"
        }
    }
}

// MARK: - Privacy
struct VimeoPrivacy: Codable {
    let view: String?
    let embed: String?
}

// MARK: - Files (Playback Sources)
struct VimeoFile: Codable {
    let quality: String?
    let type: String?
    let link: String?
}
