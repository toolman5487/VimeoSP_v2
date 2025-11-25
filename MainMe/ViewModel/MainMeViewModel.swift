//
//  MainMeViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/11/18.
//

import Foundation
import Combine

enum PictureSizeType: Int, CaseIterable {
    case size30 = 30
    case size72 = 72
    case size75 = 75
    case size100 = 100
    case size144 = 144
    case size216 = 216
    case size288 = 288
    case size300 = 300
    case size360 = 360
}

class MainMeViewModel {
    
    static let shared = MainMeViewModel()
    
    private let service: MainMeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meModel: MainMeModel?
    @Published var isLoading = false
    @Published var error: Error?
    
    private init(service: MainMeServiceProtocol = MainMeService()) {
        self.service = service
    }
    
    func fetchMe() {
        guard meModel == nil && !isLoading else { return }
        
        isLoading = true
        error = nil
        
        service.fetchMe()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] meModel in
                    self?.meModel = meModel
                }
            )
            .store(in: &cancellables)
    }
    
    var accountUppercased: String {
        return meModel?.account.uppercased() ?? "FREE"
    }
    
    func getAvatarImageURL(size: PictureSizeType) -> String? {
        guard let pictures = meModel?.pictures else { return nil }
        
        if let targetSize = pictures.sizes.first(where: { $0.width == size.rawValue }) {
            return targetSize.link
        }
        
        let sortedSizes = pictures.sizes.sorted { $0.width < $1.width }
        if size.rawValue < sortedSizes.first?.width ?? 0 {
            return sortedSizes.first?.link
        }
        if size.rawValue > sortedSizes.last?.width ?? 0 {
            return sortedSizes.last?.link
        }
        
        let closestSize = sortedSizes.min { abs($0.width - size.rawValue) < abs($1.width - size.rawValue) }
        return closestSize?.link ?? pictures.baseLink
    }

    enum EntranceType: CaseIterable {
        case videos, likes, following, albums, pictures, channels, groups, teams
        
        var title: String {
            switch self {
            case .videos: return "Videos"
            case .likes: return "Likes"
            case .following: return "Following"
            case .albums: return "Albums"
            case .pictures: return "Pictures"
            case .channels: return "Channels"
            case .groups: return "Groups"
            case .teams: return "Teams"
            }
        }
        
        var icon: String {
            switch self {
            case .videos: return "video.fill"
            case .likes: return "heart.fill"
            case .following: return "person.2"
            case .albums: return "photo.on.rectangle"
            case .pictures: return "photo.fill"
            case .channels: return "tv.fill"
            case .groups: return "person.3.fill"
            case .teams: return "person.3.sequence.fill"
            }
        }
        
        var path: String {
            switch self {
            case .videos: return "/me/videos"
            case .likes: return "/me/likes"
            case .following: return "/me/following"
            case .albums: return "/me/albums"
            case .pictures: return "/me/pictures"
            case .channels: return "/me/channels"
            case .groups: return "/me/groups"
            case .teams: return "/me/teams"
            }
        }
    }
    
    var entranceItems: [IconStatItemCollectionView.Displayable] {
        EntranceType.allCases.map { type in
            IconStatItemModel(title: type.title, icon: type.icon, path: type.path)
        }
    }
}
