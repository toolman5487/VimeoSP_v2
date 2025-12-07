//
//  HomeSearchService.swift
//  VimeoSP_v2
//
//  Created by Willy Hsu on 2025/12/3.
//

import Foundation
import Combine

// MARK: - Protocol

protocol HomeSearchServiceProtocol {
    func search(query: String, type: SearchPath, page: Int?, perPage: Int?) -> AnyPublisher<VimeoSearchResponse, Error>
}

// MARK: - Implementation

final class HomeSearchService: HomeSearchServiceProtocol {
    
    func search(query: String, type: SearchPath, page: Int? = nil, perPage: Int? = nil) -> AnyPublisher<VimeoSearchResponse, Error> {
        Future { promise in
            guard !query.isEmpty else {
                promise(.failure(APIError.invalidResponse))
                return
            }
            
            var parameters: [String: Any] = ["query": query]
            
            if let page {
                parameters["page"] = page
            }
            
            if let perPage {
                parameters["per_page"] = perPage
            }
            
            APIConfig.APIGET(path: type.path, parameters: parameters) { result in
                switch result {
                case .success(let data):
                    do {
                        let searchResponse = try JSONDecoder().decode(VimeoSearchResponse.self, from: data)
                        promise(.success(searchResponse))
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
