//
//  VideoPlayerViewModel.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import Combine

final class VideoPlayerViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    
    @Published private(set) var videoModel: VideoPlayerModel?
    
    // MARK: - Private Properties
    
    private let service: VideoPlayerServiceProtocol
    
    // MARK: - Initialization
    
    init(service: VideoPlayerServiceProtocol = VideoPlayerService()) {
        self.service = service
        super.init()
    }
    
    // MARK: - Public Methods
    
    func fetchVideo(videoId: String) {
        guard !videoId.isEmpty, !isLoading else { return }
        
        isLoading = true
        error = nil
        
        service.fetchVideo(videoId: videoId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.handleCompletion(completion)
                },
                receiveValue: { [weak self] videoModel in
                    self?.videoModel = videoModel
                }
            )
            .store(in: &cancellables)
    }
    
    func clearVideo() {
        videoModel = nil
        error = nil
    }
}
