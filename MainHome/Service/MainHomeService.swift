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
            let parameters = self.buildParameters(for: sort, page: page, perPage: perPage)
            
            APIConfig.APIGET(path: "/videos", parameters: parameters) { result in
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
    
    private func buildParameters(for sort: VideoSortType, page: Int?, perPage: Int?) -> [String: Any] {
        var parameters: [String: Any] = ["query": "video"]
        
        switch sort {
        case .popular:
            parameters["sort"] = "plays"
            parameters["direction"] = "desc"
        case .trending:
            parameters["sort"] = "relevant"
            parameters["direction"] = "desc"
        case .date:
            parameters["sort"] = "date"
            parameters["direction"] = "desc"
        case .alphabetical:
            parameters["sort"] = "alphabetical"
            parameters["direction"] = "asc"
        }
        
        if let page {
            parameters["page"] = page
        }
        
        if let perPage {
            parameters["per_page"] = perPage
        }
        
        return parameters
    }
}

