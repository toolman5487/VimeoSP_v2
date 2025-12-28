//
//  MainHomeViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import Combine

final class MainHomeViewModel: BaseViewModel {
    
    private let service: MainHomeServiceProtocol
    
    @Published private(set) var videoLists: [VideoSortType: [MainHomeVideo]] = [:]
    @Published private(set) var isLoadingLists: [VideoSortType: Bool] = [:]
    
    private var activeRequests: [VideoSortType: AnyCancellable] = [:]
    
    init(service: MainHomeServiceProtocol = MainHomeService()) {
        self.service = service
        super.init()
    }
    
    func fetchAllVideoLists() {
        guard !isLoading else { return }
        
        isLoading = true
        resetError()
        
        [.popular, .trending, .date].forEach { fetchVideos(for: $0) }
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
        isLoading = isLoadingLists.values.contains(true)
    }
    
    func getVideos(for sortType: VideoSortType) -> [MainHomeVideo] {
        videoLists[sortType] ?? []
    }
    
    func getVideoURL(for video: MainHomeVideo) -> String? {
        guard let videoId = video.videoId else { return nil }
        return URLConfig.frontendBaseURL.appendingPathComponent(videoId).absoluteString
    }
}

