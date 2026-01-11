//
//  MainHomeViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import Combine

enum MainHomeSectionType {
    case carousel
    case videoSection(VideoSortType)
    case watchHistory
}

final class MainHomeViewModel: BaseViewModel {
    
    private let service: MainHomeServiceProtocol
    
    private let sections: [VideoSortType] = [.trending, .date]
    
    @Published private(set) var videoLists: [VideoSortType: [MainHomeVideo]] = [:]
    @Published private(set) var isLoadingLists: [VideoSortType: Bool] = [:]
    @Published private(set) var watchHistory: [MainHomeVideo] = []
    @Published private(set) var isLoadingWatchHistory: Bool = false
    
    private var activeRequests: [VideoSortType: AnyCancellable] = [:]
    private var watchHistoryCancellable: AnyCancellable?
    
    init(service: MainHomeServiceProtocol = MainHomeService()) {
        self.service = service
        super.init()
    }
    
    func fetchAllVideoLists() {
        guard !isLoading else { return }
        
        isLoading = true
        resetError()
        
        [.popular, .trending, .date].forEach { fetchVideos(for: $0) }
        fetchWatchHistory()
    }
    
    func fetchWatchHistory() {
        guard !isLoadingWatchHistory else { return }
        
        isLoadingWatchHistory = true
        
        watchHistoryCancellable = service.fetchWatchHistory(page: 1, perPage: 10)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoadingWatchHistory = false
                    self.updateOverallLoadingState()
                    if case .failure(let error) = completion {
                        if let apiError = error as? APIError {
                            self.error = apiError
                        } else {
                            self.error = APIError.unknown(error)
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    if let data = response.data {
                        self.watchHistory = data
                    }
                    self.isLoadingWatchHistory = false
                    self.updateOverallLoadingState()
                }
            )
        
        watchHistoryCancellable?.store(in: &cancellables)
    }
    
    private func fetchVideosPublisher(for sortType: VideoSortType) -> AnyPublisher<Void, Error> {
        guard isLoadingLists[sortType] != true else {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        isLoadingLists[sortType] = true
        
        return service.fetchVideos(sort: sortType, page: 1, perPage: 10)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] response in
                    guard let self = self else { return }
                    if let data = response.data, !data.isEmpty {
                        self.videoLists[sortType] = data
                    }
                    self.isLoadingLists[sortType] = false
                    self.updateOverallLoadingState()
                },
                receiveCompletion: { [weak self] _ in
                    guard let self = self else { return }
                    self.isLoadingLists[sortType] = false
                    self.updateOverallLoadingState()
                    self.activeRequests.removeValue(forKey: sortType)
                }
            )
            .map { _ in () }
            .catch { [weak self] error -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                if let apiError = error as? APIError {
                    self.error = apiError
                } else {
                    self.error = APIError.unknown(error)
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchVideos(for sortType: VideoSortType) {
        guard activeRequests[sortType] == nil else { return }
        
        let cancellable = fetchVideosPublisher(for: sortType)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
        
        activeRequests[sortType] = cancellable
        cancellable.store(in: &cancellables)
    }
    
    private func updateOverallLoadingState() {
        isLoading = isLoadingLists.values.contains(true) || isLoadingWatchHistory
    }
    
    func getVideos(for sortType: VideoSortType) -> [MainHomeVideo] {
        videoLists[sortType] ?? []
    }
    
    func isLoading(for sortType: VideoSortType) -> Bool {
        isLoadingLists[sortType] ?? false
    }
    
    func getVideoURL(for video: MainHomeVideo) -> String? {
        guard let videoId = video.videoId else { return nil }
        return URLConfig.frontendBaseURL.appendingPathComponent(videoId).absoluteString
    }
    
    var visibleSections: [VideoSortType] {
        sections.filter { shouldShowSection($0) }
    }
    
    var shouldShowWatchHistory: Bool {
        !watchHistory.isEmpty || isLoadingWatchHistory
    }
    
    var totalItemCount: Int {
        let carouselCount = 1
        let visibleSectionsCount = visibleSections.count
        let watchHistoryCount = shouldShowWatchHistory ? 1 : 0
        return carouselCount + visibleSectionsCount + watchHistoryCount
    }
    
    private func shouldShowSection(_ sortType: VideoSortType) -> Bool {
        let videos = getVideos(for: sortType)
        let isLoading = isLoading(for: sortType)
        return !videos.isEmpty || isLoading
    }
    
    func getSectionType(at index: Int) -> MainHomeSectionType? {
        guard index >= 0, index < totalItemCount else { return nil }
        
        if index == 0 {
            return .carousel
        }
        
        let visibleSections = visibleSections
        let watchHistoryIndex = totalItemCount - 1
        
        if shouldShowWatchHistory && index == watchHistoryIndex {
            return .watchHistory
        }
        
        let sectionIndex = index - 1
        if sectionIndex >= 0 && sectionIndex < visibleSections.count {
            return .videoSection(visibleSections[sectionIndex])
        }
        
        return nil
    }
    
    func getSectionData(for sectionType: MainHomeSectionType) -> (videos: [MainHomeVideo], isLoading: Bool, title: String)? {
        switch sectionType {
        case .carousel:
            return (getVideos(for: .popular), isLoading(for: .popular), "Popular")
        case .videoSection(let sortType):
            return (getVideos(for: sortType), isLoading(for: sortType), sortType.displayName)
        case .watchHistory:
            return (watchHistory, isLoadingWatchHistory, "Watch History")
        }
    }
    
    func getVideosForIndexPath(_ index: Int) -> [MainHomeVideo]? {
        guard let sectionType = getSectionType(at: index) else { return nil }
        
        switch sectionType {
        case .carousel:
            return getVideos(for: .popular)
        case .videoSection(let sortType):
            return getVideos(for: sortType)
        case .watchHistory:
            return watchHistory
        }
    }
}

