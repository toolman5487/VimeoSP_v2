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
    
    init(service: MainHomeServiceProtocol = MainHomeService()) {
        self.service = service
        super.init()
    }
    
    func fetchAllVideoLists() {
        guard !isLoading else { return }
        
        isLoading = true
        resetError()
        
        let priorityTypes: [VideoSortType] = [.date, .popular, .trending]
        let deferredTypes: [VideoSortType] = [.alphabetical]
        
        fetchVideosBatch(types: priorityTypes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.fetchVideosBatch(types: deferredTypes)
        }
    }
    
    private func fetchVideosBatch(types: [VideoSortType]) {
        types.forEach { sortType in
            fetchVideos(for: sortType)
        }
    }
    
    func fetchVideos(for sortType: VideoSortType) {
        isLoadingLists[sortType] = true
        
        service.fetchVideos(sort: sortType, page: 1, perPage: 10)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoadingLists[sortType] = false
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
                    self.videoLists[sortType] = response.data ?? []
                    self.isLoadingLists[sortType] = false
                    self.updateOverallLoadingState()
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateOverallLoadingState() {
        isLoading = isLoadingLists.values.contains(true)
    }
    
    func getVideos(for sortType: VideoSortType) -> [MainHomeVideo] {
        videoLists[sortType] ?? []
    }
    
    func isLoading(for sortType: VideoSortType) -> Bool {
        isLoadingLists[sortType] ?? false
    }
}

