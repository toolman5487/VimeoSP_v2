//
//  MainMeModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation

struct MainMeModel: Codable {
    let uri: String
    let name: String
    let link: String
    let capabilities: Capabilities?
    let location: String?
    let gender: String?
    let bio: String?
    let shortBio: String?
    let createdTime: String
    let pictures: Pictures?
    let websites: [Website]?
    let metadata: Metadata?
    let locationDetails: LocationDetails?
    let skills: [Skill]?
    let availableForHire: Bool?
    let canWorkRemotely: Bool?
    let preferences: Preferences?
    let contentFilter: [String]?
    let resourceKey: String
    let account: String

    enum CodingKeys: String, CodingKey {
        case uri, name, link, capabilities, location, gender, bio
        case shortBio = "short_bio"
        case createdTime = "created_time"
        case pictures, websites, metadata
        case locationDetails = "location_details"
        case skills
        case availableForHire = "available_for_hire"
        case canWorkRemotely = "can_work_remotely"
        case preferences
        case contentFilter = "content_filter"
        case resourceKey = "resource_key"
        case account
    }
}

struct Capabilities: Codable {
    let hasLiveSubscription: Bool
}

struct Pictures: Codable {
    let uri: String
    let active: Bool
    let type: String
    let baseLink: String
    let sizes: [PictureSize]
    let resourceKey: String
    let defaultPicture: Bool

    enum CodingKeys: String, CodingKey {
        case uri, active, type
        case baseLink = "base_link"
        case sizes
        case resourceKey = "resource_key"
        case defaultPicture = "default_picture"
    }
}

struct PictureSize: Codable {
    let width: Int
    let height: Int
    let link: String
}

struct Website: Codable {
    let uri: String
    let name: String?
    let link: String
    let type: String
    let description: String?
}

struct Metadata: Codable {
    let connections: Connections
}

struct Connections: Codable {
    let albums: Connection?
    let appearances: Connection?
    let categories: Connection?
    let channels: Connection?
    let feed: Connection?
    let followers: Connection?
    let following: Connection?
    let groups: Connection?
    let likes: Connection?
    let membership: Connection?
    let moderatedChannels: Connection?
    let portfolios: Connection?
    let videos: Connection?
    let watchlater: Connection?
    let shared: Connection?
    let pictures: Connection?
    let watchedVideos: Connection?
    let foldersRoot: Connection?
    let folders: Connection?
    let teams: Connection?
    let block: Connection?

    enum CodingKeys: String, CodingKey {
        case albums, appearances, categories, channels, feed, followers, following, groups, likes, membership
        case moderatedChannels = "moderated_channels"
        case portfolios, videos, watchlater, shared, pictures
        case watchedVideos = "watched_videos"
        case foldersRoot = "folders_root"
        case folders, teams, block
    }
}

struct Connection: Codable {
    let uri: String
    let options: [String]
    let total: Int?
}

struct LocationDetails: Codable {
    let formattedAddress: String
    let latitude: Double
    let longitude: Double
    let city: String
    let state: String
    let neighborhood: String?
    let subLocality: String?
    let stateIsoCode: String
    let country: String
    let countryIsoCode: String

    enum CodingKeys: String, CodingKey {
        case formattedAddress = "formatted_address"
        case latitude, longitude, city, state, neighborhood
        case subLocality = "sub_locality"
        case stateIsoCode = "state_iso_code"
        case country
        case countryIsoCode = "country_iso_code"
    }
}

struct Skill: Codable {
    let uri: String
    let name: String
}

struct Preferences: Codable {
    let videos: VideoPreferences?
    let webinarRegistrantLowerWatermarkBannerDismissed: [String]?

    enum CodingKeys: String, CodingKey {
        case videos
        case webinarRegistrantLowerWatermarkBannerDismissed = "webinar_registrant_lower_watermark_banner_dismissed"
    }
}

struct VideoPreferences: Codable {
    let rating: [String]
    let autoccDisplayEnabledByDefault: Bool
    let license: String?
    let hideStats: Bool
    let privacy: Privacy?

    enum CodingKeys: String, CodingKey {
        case rating
        case autoccDisplayEnabledByDefault = "autocc_display_enabled_by_default"
        case license
        case hideStats = "hide_stats"
        case privacy
    }
}

struct Privacy: Codable {
    let view: String
    let comments: String
    let embed: String
    let download: Bool
    let add: Bool
    let allowShareLink: Bool

    enum CodingKeys: String, CodingKey {
        case view, comments, embed, download, add
        case allowShareLink = "allow_share_link"
    }
}
