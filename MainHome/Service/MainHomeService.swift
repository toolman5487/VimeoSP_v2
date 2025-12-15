//
//  MainHomeService.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/11.
//

import Foundation
import Combine

protocol MainHomeServiceProtocol {
    func fetchVideos(sort: VideoSortType, page: Int?, perPage: Int?) -> AnyPublisher<MainHomeVideoListResponse, Error>
}

final class MainHomeService: MainHomeServiceProtocol {
    
    func fetchVideos(sort: VideoSortType, page: Int? = nil, perPage: Int? = nil) -> AnyPublisher<MainHomeVideoListResponse, Error> {
        Future { promise in
            var parameters: [String: Any] = [
                "sort": sort.rawValue,
                "direction": "desc"
            ]
            
            if let page {
                parameters["page"] = page
            }
            
            if let perPage {
                parameters["per_page"] = perPage
            }
            
            APIConfig.APIGET(path: SearchPath.videos.path, parameters: parameters) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(MainHomeVideoListResponse.self, from: data)
                        promise(.success(response))
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

