//
//  VideoPlayerModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation

// MARK: - Video Player Response

struct VideoPlayerModel: Codable {
    let uri: String?
    let name: String?
    let description: String?
    let type: String?
    let link: String?
    let duration: Int?
    let width: Int?
    let height: Int?
    let createdTime: String?
    let modifiedTime: String?
    let releaseTime: String?
    let privacy: VimeoPrivacy?
    let pictures: VimeoPictures?
    let stats: VimeoStats?
    let user: VimeoUser?
    let play: VimeoPlay?
    let download: [VimeoDownload]?
    let status: String?
    let resourceKey: String?
    let isPlayable: Bool?
    let hasAudio: Bool?
    
    enum CodingKeys: String, CodingKey {
        case uri, name, description, type, link, duration, width, height
        case createdTime = "created_time"
        case modifiedTime = "modified_time"
        case releaseTime = "release_time"
        case privacy, pictures, stats, user, play, download, status
        case resourceKey = "resource_key"
        case isPlayable = "is_playable"
        case hasAudio = "has_audio"
    }
    
    var formattedDuration: String? {
        duration?.formattedDuration()
    }
    
    var formattedStats: String? {
        stats?.formattedPlays
    }
    
    var thumbnailURL: String? {
        pictures?.largestPictureURL
    }
    
    var mediumThumbnailURL: String? {
        pictures?.mediumPictureURL
    }
    
    var videoId: String? {
        guard let uri = uri else { return nil }
        let components = uri.split(separator: "/")
        return components.isEmpty ? nil : String(components.last ?? "")
    }
    
    var playableURL: String? {
        play?.hls?.link ?? play?.progressive?.first?.url
    }
}

// MARK: - Play

struct VimeoPlay: Codable {
    let status: String?
    let hls: VimeoPlayHLS?
    let progressive: [VimeoPlayProgressive]?
    let dash: VimeoPlayDash?
}

struct VimeoPlayHLS: Codable {
    let link: String?
    let linkExpirationTime: String?
    let allResolutions: Bool?
    
    enum CodingKeys: String, CodingKey {
        case link
        case linkExpirationTime = "link_expiration_time"
        case allResolutions = "all_resolutions"
    }
}

struct VimeoPlayProgressive: Codable {
    let profile: String?
    let width: Int?
    let mime: String?
    let fps: Double?
    let url: String?
    let quality: String?
    let id: String?
    let origin: String?
    let height: Int?
}

struct VimeoPlayDash: Codable {
    let link: String?
    let linkExpirationTime: String?
    
    enum CodingKeys: String, CodingKey {
        case link
        case linkExpirationTime = "link_expiration_time"
    }
}

// MARK: - Download

struct VimeoDownload: Codable {
    let quality: String?
    let type: String?
    let width: Int?
    let height: Int?
    let expires: String?
    let link: String?
    let createdTime: String?
    let size: Int?
    let md5: String?
    let fps: Double?
    let sizeShort: String?
    let publicName: String?
    let sizeLong: String?
    
    enum CodingKeys: String, CodingKey {
        case quality, type, width, height, expires, link, size, md5, fps, publicName
        case createdTime = "created_time"
        case sizeShort = "size_short"
        case sizeLong = "size_long"
    }
}

