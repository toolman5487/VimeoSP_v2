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
    
    private let requestQueue = DispatchQueue(label: "com.vimeo.mainhome.service", qos: .utility)
    
    func fetchVideos(sort: VideoSortType, page: Int? = nil, perPage: Int? = nil) -> AnyPublisher<MainHomeVideoListResponse, Error> {
        let parameters = buildParameters(for: sort, page: page, perPage: perPage)
        
        return Deferred {
            Future { promise in
                APIConfig.APIGET(path: "/videos", parameters: parameters) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let response = try JSONDecoder().decode(MainHomeVideoListResponse.self, from: data)
                            promise(.success(response))
                        } catch {
                            promise(.failure(APIError.decodingError(error)))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .retry(2)
        .subscribe(on: requestQueue)
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
    
        if let page = page, page > 0 {
            parameters["page"] = page
        }
        
        if let perPage = perPage, perPage > 0, perPage <= 100 {
            parameters["per_page"] = perPage
        }
        
        return parameters
    }
}

