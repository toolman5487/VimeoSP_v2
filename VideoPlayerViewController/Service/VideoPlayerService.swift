//
//  VideoPlayerService.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/8.
//

import Foundation
import Combine

// MARK: - Protocol

protocol VideoPlayerServiceProtocol {
    func fetchVideo(videoId: String) -> AnyPublisher<VideoPlayerModel, Error>
}

// MARK: - Implementation

final class VideoPlayerService: VideoPlayerServiceProtocol {
    
    func fetchVideo(videoId: String) -> AnyPublisher<VideoPlayerModel, Error> {
        Future { promise in
            guard !videoId.isEmpty else {
                promise(.failure(APIError.invalidResponse))
                return
            }
            
            APIConfig.APIGET(path: VideoPath.video(videoId: videoId).path) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let videoModel = try decoder.decode(VideoPlayerModel.self, from: data)
                        promise(.success(videoModel))
                    } catch {
                        promise(.failure(APIError.decodingError(error)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
